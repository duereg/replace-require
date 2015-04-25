chai = require 'chai'
sinon = require 'sinon'
# using compiled JavaScript file here to be sure module works
replaceRequire = require '../lib/replace-require.js'

expect = chai.expect
chai.use require 'sinon-chai'

describe 'replace-require', ->
  it 'works', ->
    expect(replaceRequire.run).to.be.ok
