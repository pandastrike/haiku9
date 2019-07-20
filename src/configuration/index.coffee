import readConfiguration from "./read"
import setupSDK from "./aws"
import preprocess from "./preprocessor"
import Utilities from "./utilities"

setup = flow [
  readConfiguration
  setupSDK
  preprocess
]

export default setup
