// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

library UriUtils {
  string constant START =
    '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">'
    "<style>"
    " text { font-family: serif; font-size: 15px; } "
    " .header { font-family: serif; font-size: 20px; } "
    "</style>"
    '<rect width="100%" height="100%" fill="#1e1e1e" stroke="#3c3c3c" stroke-width="1" />';
  string constant END = "</svg>";

  string constant ATTRS_HEADER_TYPE = ' x="50%" class="header" text-anchor="middle" fill="#4ec9b0" ';
  string constant ATTRS_BASE = ' fill="#969696" ';
  string constant ATTRS_NUM = ' fill="#b5cea8" ';
  string constant ATTRS_STRING = ' fill="#ce9178" ';
  string constant ATTRS_METHOD = ' fill="#dcdcaa" ';
  string constant ATTRS_KEY = ' fill="#9cdcfe" ';
  string constant ATTRS_TYPE = ' fill="#4ec9b0" ';
}
