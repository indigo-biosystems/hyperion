require 'hyperion'

describe ClientErrorResponse do
  describe '::from_attrs' do
    it 'creates a ClientErrorResponse from a hash' do
      hash = {
          'message' => 'oops',
          'errors' => [ make_error_attrs('assay') ]
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

  describe '::new' do
    it 'accepts splatted errors' do
      assert(ClientErrorResponse.new('oops', make_error('one')),
             %w(one))
      assert(ClientErrorResponse.new('oops', make_error('one'), make_error('two')),
             %w(one two))
    end
    it 'accepts errors as an array' do
      assert(ClientErrorResponse.new('oops', [make_error('one'), make_error('two')]),
             %w(one two))
    end

    def assert(actual_cer, expected_resources)
      expect(actual_cer.errors.map(&:resource)).to eql expected_resources
    end
  end

  def make_error(resource)
    ErrorInfo.from_attrs(make_error_attrs(resource))
  end

  def make_error_attrs(resource)
    {
        'code' => 'missing',
        'resource' => resource,
        'field' => 'name',
        'value' => 'foo',
        'reason' => 'because'
    }
  end
end
