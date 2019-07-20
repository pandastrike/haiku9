import {flow} from "panda-garden"
import readConfiguration from "./read"
import setupSDK from "./aws"
import preprocess from "./preprocessor"

setup = flow [
  readConfiguration
  setupSDK
  preprocess
]

export default setup
