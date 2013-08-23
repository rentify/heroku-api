require 'spec_helper'

describe Heroku::Config do

  it "should respond to #auth_token" do
    expect(described_class).to respond_to(:auth_token)
  end

  describe "#auth_token_update" do
    let(:email)   { "joe.bloggs@example.com" }
    let(:api_key) { "01234567-89ab-cdef-0123-456789abcdef" }

    it "should create a base64 encoded auth token" do
      described_class.auth_token_update(email, api_key)
      expect(described_class.auth_token).to eq(Base64.encode64("#{email}:#{api_key}").strip)
    end

    [:email, :api_key].each do |argument|
      context "when no #{argument.to_s} is provided" do
        let(argument) { nil }
        let(error) { ArgumentError }

        it "should raise an error" do
          expect { described_class.auth_token_update(email, api_key) }.to raise_error(error)
        end

        it "should leave the auth_token unchanged" do
          expect { described_class.auth_token_update(email, api_key) rescue error }.not_to change(described_class, :auth_token)
        end
      end
    end
  end


end
