require 'spec_helper'

describe Heroku::Conn do

  describe ".check_response" do
    context "when the response is unsuccessful" do
      let(:unsuccessful_response) { Net::HTTPClientError.new() }

      it "should raise a error" do
        expect { described_class.send(:check_response, nil, nil, response) }.to raise_error
      end
    end
  end
end
