"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.handler = void 0;

require("source-map-support/register");

var _errorResponse = _interopRequireDefault(require("./error-response"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// Generated by CoffeeScript 2.4.1
var handler;
exports.handler = handler;

exports.handler = handler = async function (event, context, callback) {
  var e, request, response;

  try {
    ({
      request,
      response
    } = event.Records[0].cf);

    if (response.status === 404) {
      return callback(null, (await (0, _errorResponse.default)(request)));
    }

    return callback(null, response);
  } catch (error) {
    e = error;
    console.log(e);
    return callback(null, response);
  }
};
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInNyYy9pbmRleC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7OztBQUFBOztBQUNBOzs7OztBQURBLElBQUEsT0FBQTs7O0FBR0Esa0JBQUEsT0FBQSxHQUFVLGdCQUFBLEtBQUEsRUFBQSxPQUFBLEVBQUEsUUFBQSxFQUFBO0FBQ1IsTUFBQSxDQUFBLEVBQUEsT0FBQSxFQUFBLFFBQUE7O0FBQUEsTUFBQTtBQUNFLEtBQUE7QUFBQSxNQUFBLE9BQUE7QUFBQSxNQUFBO0FBQUEsUUFBc0IsS0FBSyxDQUFDLE9BQU4sQ0FBYyxDQUFkLEVBQXRCLEVBQUE7O0FBRUEsUUFBRyxRQUFRLENBQVIsTUFBQSxLQUFILEdBQUEsRUFBQTtBQUNFLGFBQU8sUUFBQSxDQUFBLElBQUEsR0FBZSxNQUFNLDRCQUQ5QixPQUM4QixDQUFyQixFQUFQOzs7V0FFRixRQUFBLENBQUEsSUFBQSxFQU5GLFFBTUUsQztBQU5GLEdBQUEsQ0FBQSxPQUFBLEtBQUEsRUFBQTtBQVFNLElBQUEsQ0FBQSxHQUFBLEtBQUE7QUFDSixJQUFBLE9BQU8sQ0FBUCxHQUFBLENBQUEsQ0FBQTtXQUNBLFFBQUEsQ0FBQSxJQUFBLEVBVkYsUUFVRSxDOztBQVhNLENBQVYiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgXCJzb3VyY2UtbWFwLXN1cHBvcnQvcmVnaXN0ZXJcIlxuaW1wb3J0IGVycm9yUmVzcG9uc2UgZnJvbSBcIi4vZXJyb3ItcmVzcG9uc2VcIlxuXG5oYW5kbGVyID0gKGV2ZW50LCBjb250ZXh0LCBjYWxsYmFjaykgLT5cbiAgdHJ5XG4gICAge3JlcXVlc3QsIHJlc3BvbnNlfSA9IGV2ZW50LlJlY29yZHNbMF0uY2ZcblxuICAgIGlmIHJlc3BvbnNlLnN0YXR1cyA9PSA0MDRcbiAgICAgIHJldHVybiBjYWxsYmFjayBudWxsLCBhd2FpdCBlcnJvclJlc3BvbnNlIHJlcXVlc3RcblxuICAgIGNhbGxiYWNrIG51bGwsIHJlc3BvbnNlXG5cbiAgY2F0Y2ggZVxuICAgIGNvbnNvbGUubG9nIGVcbiAgICBjYWxsYmFjayBudWxsLCByZXNwb25zZVxuXG5leHBvcnQge2hhbmRsZXJ9XG4iXSwic291cmNlUm9vdCI6Ii4uIn0=
//# sourceURL=/Users/david/repos/haiku9/edge-lambdas/primary/origin-response/src/index.coffee