require "spec_helper"

describe OkuribitoRails::StartObserver do
  describe "#start" do
    let(:prohibit_observation) { false }
    let(:already_migrated) { true }
    let(:setting_path) { "spec/support/test_config.yml" }
    let(:start_observer) { OkuribitoRails::StartObserver.new }

    before do
      allow(start_observer).to receive(:prohibit_observation?).and_return(prohibit_observation)
      allow(start_observer).to receive(:already_migrated?).and_return(already_migrated)
      allow(start_observer).to receive(:setting_path).and_return(setting_path)
      allow(start_observer).to receive(:regist_method)
      allow(start_observer).to receive(:start_observer)
      start_observer.start
    end

    context "allowed env / after_migrate" do
      it { expect(start_observer).to have_received(:regist_method) }
      it { expect(start_observer).to have_received(:start_observer) }
    end

    context "prohibited env" do
      let(:prohibit_observation) { true }
      it { expect(start_observer).not_to have_received(:regist_method) }
      it { expect(start_observer).not_to have_received(:start_observer) }
    end

    context "already_migrated" do
      let(:already_migrated) { false }
      it { expect(start_observer).not_to have_received(:regist_method) }
      it { expect(start_observer).not_to have_received(:start_observer) }
    end
  end
end
