import {flow} from "panda-garden"
import readConfiguration from "./read"
import preprocess from "./preprocessor"

setup = flow [
  readConfiguration
  preprocess
]

export default setup
