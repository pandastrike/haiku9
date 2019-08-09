import {flow} from "panda-garden"

import setEnvironment from "./environment"
import setHostnames from "./hostnames"
import setCache from "./cache"
import setEdgeLambas from "./lambdas"

preprocess = flow [
  setEnvironment
  setHostnames
  setCache
  setEdgeLambdas
]

export default preprocess
