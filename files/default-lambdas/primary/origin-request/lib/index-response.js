"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;

var _path = require("path");

var _pandaQuill = require("panda-quill");

// Generated by CoffeeScript 2.4.1
var paths, response;
paths = {
  br: async function (path) {
    path = (0, _path.resolve)(__dirname, "index-files", "brotli");
    return {
      body: (await (0, _pandaQuill.read)(path, "buffer")).toString("base64"),
      bodyEncoding: "base64"
    };
  }(void 0),
  gzip: async function (path) {
    path = (0, _path.resolve)(__dirname, "index-files", "gzip");
    return {
      body: (await (0, _pandaQuill.read)(path, "buffer")).toString("base64"),
      bodyEncoding: "base64"
    };
  }(void 0),
  identity: async function (path) {
    path = (0, _path.resolve)(__dirname, "index-files", "identity");
    return {
      body: (await (0, _pandaQuill.read)(path, "buffer")).toString("utf8"),
      bodyEncoding: "text"
    };
  }(void 0)
};

response = async function (request) {
  var body, bodyEncoding, encoding;
  encoding = request.headers["accept-encoding"][0].value;
  ({
    body,
    bodyEncoding
  } = await paths[encoding]);
  return {
    status: "200",
    statusDescription: "200 OK",
    body: body,
    bodyEncoding: bodyEncoding,
    headers: {
      "access-control-allow-origin": [{
        key: "Access-Control-Allow-Origin",
        value: "*"
      }],
      "content-type": [{
        key: "Content-Type",
        value: "text/html"
      }],
      "content-encoding": [{
        key: "Content-Encoding",
        value: encoding
      }]
    }
  };
};

var _default = response;
exports.default = _default;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInNyYy9pbmRleC1yZXNwb25zZS5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7OztBQUFBOztBQUNBOzs7QUFEQSxJQUFBLEtBQUEsRUFBQSxRQUFBO0FBR0EsS0FBQSxHQUNFO0FBQUEsRUFBQSxFQUFBLEVBQU8sZ0JBQUEsSUFBQSxFQUFBO0FBQ0wsSUFBQSxJQUFBLEdBQU8sbUJBQUEsU0FBQSxFQUFBLGFBQUEsRUFBQSxRQUFBLENBQVA7V0FDQTtBQUFBLE1BQUEsSUFBQSxFQUFNLENBQUMsTUFBTSxzQkFBQSxJQUFBLEVBQVAsUUFBTyxDQUFQLEVBQUEsUUFBQSxDQUFOLFFBQU0sQ0FBTjtBQUNBLE1BQUEsWUFBQSxFQUFjO0FBRGQsSztBQUZFLEdBQUcsQ0FBTSxLQUFiLENBQU8sQ0FBUDtBQUlBLEVBQUEsSUFBQSxFQUFTLGdCQUFBLElBQUEsRUFBQTtBQUNQLElBQUEsSUFBQSxHQUFPLG1CQUFBLFNBQUEsRUFBQSxhQUFBLEVBQUEsTUFBQSxDQUFQO1dBQ0E7QUFBQSxNQUFBLElBQUEsRUFBTSxDQUFDLE1BQU0sc0JBQUEsSUFBQSxFQUFQLFFBQU8sQ0FBUCxFQUFBLFFBQUEsQ0FBTixRQUFNLENBQU47QUFDQSxNQUFBLFlBQUEsRUFBYztBQURkLEs7QUFGSSxHQUFHLENBQU0sS0FKZixDQUlTLENBSlQ7QUFRQSxFQUFBLFFBQUEsRUFBYSxnQkFBQSxJQUFBLEVBQUE7QUFDWCxJQUFBLElBQUEsR0FBTyxtQkFBQSxTQUFBLEVBQUEsYUFBQSxFQUFBLFVBQUEsQ0FBUDtXQUNBO0FBQUEsTUFBQSxJQUFBLEVBQU0sQ0FBQyxNQUFNLHNCQUFBLElBQUEsRUFBUCxRQUFPLENBQVAsRUFBQSxRQUFBLENBQU4sTUFBTSxDQUFOO0FBQ0EsTUFBQSxZQUFBLEVBQWM7QUFEZCxLO0FBRlEsR0FBRyxDQUFNLEtBQVQsQ0FBRztBQVJiLENBREY7O0FBY0EsUUFBQSxHQUFXLGdCQUFBLE9BQUEsRUFBQTtBQUVULE1BQUEsSUFBQSxFQUFBLFlBQUEsRUFBQSxRQUFBO0FBQUEsRUFBQSxRQUFBLEdBQVcsT0FBTyxDQUFDLE9BQVIsQ0FBZ0IsaUJBQWhCLEVBQW1DLENBQW5DLEVBQXNDLEtBQWpEO0FBQ0EsR0FBQTtBQUFBLElBQUEsSUFBQTtBQUFBLElBQUE7QUFBQSxNQUF1QixNQUFNLEtBQU0sQ0FBbkMsUUFBbUMsQ0FBbkM7U0FFQTtBQUFBLElBQUEsTUFBQSxFQUFBLEtBQUE7QUFDQSxJQUFBLGlCQUFBLEVBREEsUUFBQTtBQUVBLElBQUEsSUFBQSxFQUZBLElBQUE7QUFHQSxJQUFBLFlBQUEsRUFIQSxZQUFBO0FBSUEsSUFBQSxPQUFBLEVBQ0U7QUFBQSxxQ0FBK0IsQ0FDN0I7QUFBQSxRQUFBLEdBQUEsRUFBQSw2QkFBQTtBQUNBLFFBQUEsS0FBQSxFQUFPO0FBRFAsT0FENkIsQ0FBL0I7QUFJQSxzQkFBZ0IsQ0FDWjtBQUFBLFFBQUEsR0FBQSxFQUFBLGNBQUE7QUFDQSxRQUFBLEtBQUEsRUFBTztBQURQLE9BRFksQ0FKaEI7QUFRQSwwQkFBb0IsQ0FDaEI7QUFBQSxRQUFBLEdBQUEsRUFBQSxrQkFBQTtBQUNBLFFBQUEsS0FBQSxFQUFPO0FBRFAsT0FEZ0I7QUFScEI7QUFMRixHO0FBTFMsQ0FBWDs7ZUF1QmUsUSIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7cmVzb2x2ZX0gZnJvbSBcInBhdGhcIlxuaW1wb3J0IHtyZWFkfSBmcm9tIFwicGFuZGEtcXVpbGxcIlxuXG5wYXRocyA9XG4gIGJyOiBkbyAocGF0aD11bmRlZmluZWQpIC0+XG4gICAgcGF0aCA9IHJlc29sdmUgX19kaXJuYW1lLCBcImluZGV4LWZpbGVzXCIsIFwiYnJvdGxpXCJcbiAgICBib2R5OiAoYXdhaXQgcmVhZCBwYXRoLCBcImJ1ZmZlclwiKS50b1N0cmluZyBcImJhc2U2NFwiXG4gICAgYm9keUVuY29kaW5nOiBcImJhc2U2NFwiXG4gIGd6aXA6IGRvIChwYXRoPXVuZGVmaW5lZCkgLT5cbiAgICBwYXRoID0gcmVzb2x2ZSBfX2Rpcm5hbWUsIFwiaW5kZXgtZmlsZXNcIiwgXCJnemlwXCJcbiAgICBib2R5OiAoYXdhaXQgcmVhZCBwYXRoLCBcImJ1ZmZlclwiKS50b1N0cmluZyBcImJhc2U2NFwiXG4gICAgYm9keUVuY29kaW5nOiBcImJhc2U2NFwiXG4gIGlkZW50aXR5OiBkbyAocGF0aD11bmRlZmluZWQpIC0+XG4gICAgcGF0aCA9IHJlc29sdmUgX19kaXJuYW1lLCBcImluZGV4LWZpbGVzXCIsIFwiaWRlbnRpdHlcIlxuICAgIGJvZHk6IChhd2FpdCByZWFkIHBhdGgsIFwiYnVmZmVyXCIpLnRvU3RyaW5nIFwidXRmOFwiXG4gICAgYm9keUVuY29kaW5nOiBcInRleHRcIlxuXG5yZXNwb25zZSA9IChyZXF1ZXN0KSAtPlxuXG4gIGVuY29kaW5nID0gcmVxdWVzdC5oZWFkZXJzW1wiYWNjZXB0LWVuY29kaW5nXCJdWzBdLnZhbHVlXG4gIHtib2R5LCBib2R5RW5jb2Rpbmd9ID0gYXdhaXQgcGF0aHNbZW5jb2RpbmddXG5cbiAgc3RhdHVzOiBcIjIwMFwiLFxuICBzdGF0dXNEZXNjcmlwdGlvbjogXCIyMDAgT0tcIlxuICBib2R5OiBib2R5XG4gIGJvZHlFbmNvZGluZzogYm9keUVuY29kaW5nXG4gIGhlYWRlcnM6XG4gICAgXCJhY2Nlc3MtY29udHJvbC1hbGxvdy1vcmlnaW5cIjogW1xuICAgICAga2V5OiBcIkFjY2Vzcy1Db250cm9sLUFsbG93LU9yaWdpblwiXG4gICAgICB2YWx1ZTogXCIqXCJcbiAgICBdXG4gICAgXCJjb250ZW50LXR5cGVcIjogW1xuICAgICAgICBrZXk6IFwiQ29udGVudC1UeXBlXCIsXG4gICAgICAgIHZhbHVlOiBcInRleHQvaHRtbFwiXG4gICAgXVxuICAgIFwiY29udGVudC1lbmNvZGluZ1wiOiBbXG4gICAgICAgIGtleTogXCJDb250ZW50LUVuY29kaW5nXCIsXG4gICAgICAgIHZhbHVlOiBlbmNvZGluZ1xuICAgIF1cblxuZXhwb3J0IGRlZmF1bHQgcmVzcG9uc2VcbiJdLCJzb3VyY2VSb290IjoiLi4ifQ==
//# sourceURL=/Users/dy/repos/pandastrike/haiku9/edge-lambdas/primary/origin-request/src/index-response.coffee