require 'hyperion'

describe ClientErrorResponse do
  describe '::from_attrs' do
    it 'creates a ClientErrorResponse from a hash' do
      hash = {
          'message' => 'oops',
          'errors' =>
              [
                 {
                     'code' => 'missing',
                     'resource' => 'assay',
                     'field' => 'name',
                     'value' => 'foo',
                     'reason' => 'because'
                 }
              ]
      }
      result = ClientErrorResponse.from_attrs(hash)
      expect(result.message).to eql 'oops'
      expect(result.errors.size).to eql 1
      error = result.errors.first
      expect(error.code).to eql 'missing'
      expect(error.resource).to eql 'assay'
      expect(error.field).to eql 'name'
      expect(error.value).to eql 'foo'
      expect(error.reason).to eql 'because'
    end
  end
end
