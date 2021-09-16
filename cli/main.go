package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"github.com/vmihailenco/msgpack/v5"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

var version = "v0.0.0"

func main() {
	if len(os.Args) > 1 {
		var nullBytes bytes.Buffer
		nullWriter := bufio.NewWriter(&nullBytes)

		globalFlags := flag.NewFlagSet("proc", flag.ExitOnError)
		globalFlags.SetOutput(nullWriter)
		globalFlags.Usage = func() {
			commandHelp()
		}

		compileFlags := flag.NewFlagSet("compile", flag.ExitOnError)
		compileFlags.SetOutput(nullWriter)
		compileFlags.Usage = func() {
			commandHelpCompile()
		}

		runFlags := flag.NewFlagSet("run", flag.ExitOnError)
		runFlags.SetOutput(nullWriter)
		runFlags.Usage = func() {
			commandHelpRun()
		}

		authorizationArg := globalFlags.String("auth", "", "")
		globalHelpArg := globalFlags.Bool("help", false, "")

		globalFlags.Parse(os.Args[1:])

		if *globalHelpArg {
			if len(globalFlags.Args()) > 0 {
				switch globalFlags.Args()[0] {
				case "help":
					commandHelp()
				case "version":
					commandHelpVersion()
				case "compile":
					commandHelpCompile()
				case "run":
					commandHelpRun()
				default:
					commandHelp()
				}
			} else {
				commandHelp()
			}

			os.Exit(0)
		}

		authorization := ensureAuth(*authorizationArg)

		switch globalFlags.Args()[0] {
		case "help":
			commandHelp()
		case "version":
			commandVersion()
		case "compile":
			compileFlags.Parse(globalFlags.Args()[1:])
			compileCommandArgs := compileFlags.Args()

			if len(compileCommandArgs) > 0 {
				commandCompile(compileCommandArgs[0], authorization)
			} else {
				commandHelpCompile()
			}
		case "run":
			runFlags.Parse(globalFlags.Args()[1:])
			runCommandArgs := runFlags.Args()

			if len(runCommandArgs) > 0 {
				commandRun(runCommandArgs[0], authorization)
			} else {
				commandHelpRun()
			}
		default:
			commandHelp()
		}
	} else {
		commandHelp()
	}
}

func commandHelp() {
	fmt.Println("Usage: proc [global options] <subcommand> [args]\n" +
		"\nAvailable commands:\n" +
		"  compile       Compiles a supported source file to a Proc AST.\n" +
		"  run           Runs a supported source file in Proc.\n" +
		"  version       Show the current version of this command-line interface.\n" +
		"\nGlobal options:\n" +
		"  -auth=AUTH    The authorization to use when interacting with Proc.")
}

func commandHelpCompile() {
	fmt.Println("Usage: proc compile [FILE]\n" +
		"\nCompile the given source file, returning the Proc AST as json.")
}

func commandHelpRun() {
	fmt.Println("Usage: proc run [FILE]\n" +
		"\nRun the given source file in Proc, returning the result as json.")
}

func commandHelpVersion() {
	fmt.Println("Usage: proc version\n" +
		"\nShow the current version of the Proc CLI.")
}

func commandVersion() {
	fmt.Println("Proc CLI " + version)
}

func commandCompile(path string, authorization string) {
	checkPath(path)

	data, error := ioutil.ReadFile(path)
	check(error)

	parts := strings.Split(path, ".")
	ext := parts[len(parts)-1]

	ast := []interface{}{
		[3]interface{}{
			"$$",
			"code",
			[2]string{"%%", string(data)}},
		[3]interface{}{
			"$$",
			"lang",
			[2]string{"%%", ext}}}

	callProc("core/compile", authorization, ast)
}

func commandRun(path string, authorization string) {
	checkPath(path)

	data, error := ioutil.ReadFile(path)
	check(error)

	parts := strings.Split(path, ".")
	ext := parts[len(parts)-1]

	ast := []interface{}{
		[3]interface{}{
			"$$",
			"proc",
			[3]interface{}{
				"{}",
				[4]interface{}{
					"()",
					"core.compile",
					[3]interface{}{
						"$$",
						"code",
						[2]string{"%%", string(data)}},
					[3]interface{}{
						"$$",
						"lang",
						[2]string{"%%", ext}}},
				[2]string{"()", "core.exec"}}}}

	callProc("core/exec", authorization, ast)
}

func check(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func checkPath(path string) {
	_, err := os.Stat(path)
	check(err)
}

func ensureAuth(authorization string) string {
	if authorization == "" {
		authorization = os.Getenv("PROC_AUTH")
	}

	if authorization == "" {
		userDirectory, _ := os.UserHomeDir()
		procAuthPath := fmt.Sprint(userDirectory, "/.proc/auth")
		_, error := os.Stat(procAuthPath)

		if error == nil {
			data, _ := ioutil.ReadFile(procAuthPath)
			authorization = strings.TrimSuffix(string(data), "\n")
		}
	}

	return authorization
}

func callProc(path string, authorization string, ast []interface{}) {
	buffer, error := msgpack.Marshal(ast)
	check(error)

	request, error := http.NewRequest("POST", "https://api.proc.dev/"+path, bytes.NewReader(buffer))
	request.Header.Add("Authorization", "bearer "+authorization)
	request.Header.Add("Content-Type", "application/vnd.proc+msgpack")
	request.Header.Add("Accept", "application/json")

	client := &http.Client{}
	response, error := client.Do(request)
	check(error)

	defer response.Body.Close()
	body, error := ioutil.ReadAll(response.Body)
	check(error)

	switch response.StatusCode {
	case 200:
		fmt.Println(string(body))
	default:
		fmt.Println(response.Status+": ", string(body))
		os.Exit(1)
	}
}
