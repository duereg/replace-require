chai = require 'chai'
sinon = require 'sinon'
walk = require 'walk'

# using compiled JavaScript file here to be sure module works
replaceRequire = require '../lib/replace-require.js'

expect = chai.expect
chai.use require 'sinon-chai'

describe 'replace-require', ->
  describe '::run', ->
    it 'is defined', ->
      expect(replaceRequire.run).to.be.ok

    describe 'when called', ->
      {walkStub, onStub, directory} = {}

      before ->
        directory = '/app'
        onStub = sinon.stub()
        walkStub = sinon.stub(walk, 'walk').returns(on: onStub)
        replaceRequire.run(directory)

      after ->
        walkStub.restore()

      it 'calls walker.walk(directory)', ->
        expect(walkStub.calledWith(directory)).to.be.true

      it 'registers walker.on(fileHandler)', ->
        expect(onStub.calledWith('file', replaceRequire.fileHandler)).to.be.true

      it 'registers walker.on(errorsHandler)', ->
        expect(onStub.calledWith('errors', replaceRequire.errorsHandler)).to.be.true

      it 'registers walker.on(endHandler)', ->
        expect(onStub.calledWith('end', replaceRequire.endHandler)).to.be.true

  describe '::fileHandler', ->
    it 'is defined', ->
      expect(replaceRequire.fileHandler).to.be.ok

  describe '::errorsHandler', ->
    it 'is defined', ->
      expect(replaceRequire.errorsHandler).to.be.ok

  describe '::endHandler', ->
    it 'is defined', ->
      expect(replaceRequire.endHandler).to.be.ok
