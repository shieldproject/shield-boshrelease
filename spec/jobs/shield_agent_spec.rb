require 'rspec'
require 'yaml'
require 'bosh/template/test'

describe 'shield-agent job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('shield-agent') }
  let(:fake_key) { "RSA PRIVATE KEY\nFOO\nBAR\n" }

  describe 'agent.key' do
    let(:template) { job.template('config/agent.key') }

    it 'raises error if given agent.key is not an RSA key' do
      expect {
        template.render("agent" => { "key" => "FOO KEY" })
      }.to raise_error "agent.key 'FOO KEY' does not look like an RSA private key"
    end

    it 'raises error if given agent.key is not set' do
      expect {
        template.render({})
      }.to raise_error /agent.key/
    end

    it 'configures key successfully' do
      config = template.render("agent" => { "key" => fake_key })
      expect(config).to eq(fake_key)
    end
  end
end
