import babel from "@rollup/plugin-babel";
import resolve from "@rollup/plugin-node-resolve";
import { terser } from "rollup-plugin-terser";

export default [
  {
    input: "index",
    plugins: [
      resolve(), babel({ babelHelpers: "bundled" })
    ],
    output: {
      name: "Proc",
      file: "dist/proc.js",
      format: "umd",
      sourcemap: true
    }
  },
  {
    input: "index",
    plugins: [
      resolve(), babel({ babelHelpers: "bundled" }), terser()
    ],
    output: {
      name: "Proc",
      file: "dist/proc.min.js",
      format: "umd",
      sourcemap: true
    }
  }
];
