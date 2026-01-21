const _ = require('lodash');

const input = require('fs').readFileSync(0, 'utf-8').trim();
// using lodash which is pre-installed
const upper = _.toUpper(input);

console.log(`Hello, ${input}`);
