"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.handler = void 0;

require("source-map-support/register");

var _path = require("path");

var _indexResponse = _interopRequireDefault(require("./index-response"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// Generated by CoffeeScript 2.4.1
var handler;
exports.handler = handler;

exports.handler = handler = async function (event, context, callback) {
  var e, request;

  try {
    ({
      request
    } = event.Records[0].cf);
    console.log({
      uri: request.uri,
      accept: request.headers["accept"][0].value,
      acceptEncoding: request.headers["accept-encoding"][0].value
    });

    if (request.uri === "/") {
      return callback(null, (await (0, _indexResponse.default)(request)));
    }

    switch (request.headers["accept-encoding"][0].value) {
      case "br":
        request.uri = (0, _path.join)("/brotli", request.uri);
        break;

      case "gzip":
        request.uri = (0, _path.join)("/gzip", request.uri);
        break;

      case "identity":
        request.uri = (0, _path.join)("/identity", request.uri);
    }

    return callback(null, request);
  } catch (error) {
    e = error;
    console.log(e);
    request.uri = (0, _path.join)("/identity", request.uri);
    return callback(null, request);
  }
};
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInNyYy9pbmRleC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7OztBQUFBOztBQUNBOztBQUNBOzs7OztBQUZBLElBQUEsT0FBQTs7O0FBSUEsa0JBQUEsT0FBQSxHQUFVLGdCQUFBLEtBQUEsRUFBQSxPQUFBLEVBQUEsUUFBQSxFQUFBO0FBQ1IsTUFBQSxDQUFBLEVBQUEsT0FBQTs7QUFBQSxNQUFBO0FBQ0UsS0FBQTtBQUFBLE1BQUE7QUFBQSxRQUFZLEtBQUssQ0FBQyxPQUFOLENBQWMsQ0FBZCxFQUFaLEVBQUE7QUFFQSxJQUFBLE9BQU8sQ0FBUCxHQUFBLENBQ0U7QUFBQSxNQUFBLEdBQUEsRUFBSyxPQUFPLENBQVosR0FBQTtBQUNBLE1BQUEsTUFBQSxFQUFRLE9BQU8sQ0FBQyxPQUFSLENBQWdCLFFBQWhCLEVBQTBCLENBQTFCLEVBRFIsS0FBQTtBQUVBLE1BQUEsY0FBQSxFQUFnQixPQUFPLENBQUMsT0FBUixDQUFnQixpQkFBaEIsRUFBbUMsQ0FBbkMsRUFBc0M7QUFGdEQsS0FERjs7QUFLQSxRQUFHLE9BQU8sQ0FBUCxHQUFBLEtBQUgsR0FBQSxFQUFBO0FBQ0UsYUFBTyxRQUFBLENBQUEsSUFBQSxHQUFlLE1BQU0sNEJBRDlCLE9BQzhCLENBQXJCLEVBQVA7OztBQUVGLFlBQU8sT0FBTyxDQUFDLE9BQVIsQ0FBZ0IsaUJBQWhCLEVBQW1DLENBQW5DLEVBQVAsS0FBQTtBQUFBLFdBQUEsSUFBQTtBQUVJLFFBQUEsT0FBTyxDQUFQLEdBQUEsR0FBYyxnQkFBQSxTQUFBLEVBQWdCLE9BQU8sQ0FBdkIsR0FBQSxDQUFkO0FBREc7O0FBRFAsV0FBQSxNQUFBO0FBSUksUUFBQSxPQUFPLENBQVAsR0FBQSxHQUFjLGdCQUFBLE9BQUEsRUFBYyxPQUFPLENBQXJCLEdBQUEsQ0FBZDtBQURHOztBQUhQLFdBQUEsVUFBQTtBQU1JLFFBQUEsT0FBTyxDQUFQLEdBQUEsR0FBYyxnQkFBQSxXQUFBLEVBQWtCLE9BQU8sQ0FBekIsR0FBQSxDQUFkO0FBTko7O1dBUUEsUUFBQSxDQUFBLElBQUEsRUFuQkYsT0FtQkUsQztBQW5CRixHQUFBLENBQUEsT0FBQSxLQUFBLEVBQUE7QUFxQk0sSUFBQSxDQUFBLEdBQUEsS0FBQTtBQUNKLElBQUEsT0FBTyxDQUFQLEdBQUEsQ0FBQSxDQUFBO0FBQ0EsSUFBQSxPQUFPLENBQVAsR0FBQSxHQUFjLGdCQUFBLFdBQUEsRUFBa0IsT0FBTyxDQUF6QixHQUFBLENBQWQ7V0FDQSxRQUFBLENBQUEsSUFBQSxFQXhCRixPQXdCRSxDOztBQXpCTSxDQUFWIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IFwic291cmNlLW1hcC1zdXBwb3J0L3JlZ2lzdGVyXCJcbmltcG9ydCB7am9pbn0gZnJvbSBcInBhdGhcIlxuaW1wb3J0IGluZGV4UmVzcG9uc2UgZnJvbSBcIi4vaW5kZXgtcmVzcG9uc2VcIlxuXG5oYW5kbGVyID0gKGV2ZW50LCBjb250ZXh0LCBjYWxsYmFjaykgLT5cbiAgdHJ5XG4gICAge3JlcXVlc3R9ID0gZXZlbnQuUmVjb3Jkc1swXS5jZlxuXG4gICAgY29uc29sZS5sb2dcbiAgICAgIHVyaTogcmVxdWVzdC51cmlcbiAgICAgIGFjY2VwdDogcmVxdWVzdC5oZWFkZXJzW1wiYWNjZXB0XCJdWzBdLnZhbHVlXG4gICAgICBhY2NlcHRFbmNvZGluZzogcmVxdWVzdC5oZWFkZXJzW1wiYWNjZXB0LWVuY29kaW5nXCJdWzBdLnZhbHVlXG5cbiAgICBpZiByZXF1ZXN0LnVyaSA9PSBcIi9cIlxuICAgICAgcmV0dXJuIGNhbGxiYWNrIG51bGwsIGF3YWl0IGluZGV4UmVzcG9uc2UgcmVxdWVzdFxuXG4gICAgc3dpdGNoIHJlcXVlc3QuaGVhZGVyc1tcImFjY2VwdC1lbmNvZGluZ1wiXVswXS52YWx1ZVxuICAgICAgd2hlbiBcImJyXCJcbiAgICAgICAgcmVxdWVzdC51cmkgPSBqb2luIFwiL2Jyb3RsaVwiLCByZXF1ZXN0LnVyaVxuICAgICAgd2hlbiBcImd6aXBcIlxuICAgICAgICByZXF1ZXN0LnVyaSA9IGpvaW4gXCIvZ3ppcFwiLCByZXF1ZXN0LnVyaVxuICAgICAgd2hlbiBcImlkZW50aXR5XCJcbiAgICAgICAgcmVxdWVzdC51cmkgPSBqb2luIFwiL2lkZW50aXR5XCIsIHJlcXVlc3QudXJpXG5cbiAgICBjYWxsYmFjayBudWxsLCByZXF1ZXN0XG5cbiAgY2F0Y2ggZVxuICAgIGNvbnNvbGUubG9nIGVcbiAgICByZXF1ZXN0LnVyaSA9IGpvaW4gXCIvaWRlbnRpdHlcIiwgcmVxdWVzdC51cmlcbiAgICBjYWxsYmFjayBudWxsLCByZXF1ZXN0XG5cbmV4cG9ydCB7aGFuZGxlcn1cbiJdLCJzb3VyY2VSb290IjoiLi4ifQ==
//# sourceURL=/Users/dy/repos/pandastrike/haiku9/edge-lambdas/primary/origin-request/src/index.coffee