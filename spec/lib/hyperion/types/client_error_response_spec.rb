require 'hyperion'

describe ClientErrorResponse do
  describe '::from_attrs' do
    it 'creates a ClientErrorResponse from a hash' do
      hash = {
          'message' => 'oops',
          'code' => 'missing',
          'errors' => [ make_error_attrs('assay') ],
          'body' => 'stuff'
      }
      result = ClientErrorResponse.from_attrs(hash)
      expect(result.message).to eql 'oops'
      expect(result.code).to eql ClientErrorCode::MISSING
      expect(result.body).to eql 'stuff'
      expect(result.errors.size).to eql 1
      error = result.errors.first
      expect(error.code).to eql ClientErrorCode::MISSING
      expect(error.resource).to eql 'assay'
      expect(error.field).to eql 'name'
      expect(error.value).to eql 'foo'
      expect(error.reason).to eql 'because'
    end
  end

  describe '::as_json' do
    it 'converts to a hash' do
      errors = [ ClientErrorDetail.new(ClientErrorCode::MISSING, 'x'),
                 ClientErrorDetail.new(ClientErrorCode::INVALID, 'x') ]
      err = ClientErrorResponse.new('oops', errors, ClientErrorCode::INVALID, 'the_body')
      result = err.as_json
      expect(result['message']).to eql 'oops'
      expect(result['code']).to eql 'invalid'
      expect(result['body']).to eql 'the_body'
      expect(result['errors'].map(&['code'])).to eql %w(missing invalid)
    end
  end

  def make_error(resource)
    ClientErrorDetail.from_attrs(make_error_attrs(resource))
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
