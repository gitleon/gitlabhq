# frozen_string_literal: true
require "spec_helper"

RSpec.describe PagesUpdateConfigurationWorker do
  describe "#perform" do
    let_it_be(:project) { create(:project) }

    it "does not break if the project doesn't exist" do
      expect { subject.perform(-1) }.not_to raise_error
    end

    it "calls the correct service" do
      expect_next_instance_of(Projects::UpdatePagesConfigurationService, project) do |service|
        expect(service).to receive(:execute).and_return({})
      end

      subject.perform(project.id)
    end

    it_behaves_like "an idempotent worker" do
      let(:job_args) { [project.id] }
      let(:pages_dir) { Dir.mktmpdir }
      let(:config_path) { File.join(pages_dir, "config.json") }

      before do
        allow(Project).to receive(:find_by_id).with(project.id).and_return(project)
        allow(project).to receive(:pages_path).and_return(pages_dir)

        # Make sure _some_ config exists
        FileUtils.touch(config_path)
      end

      after do
        FileUtils.remove_entry(pages_dir)
      end

      it "only updates the config file once" do
        described_class.new.perform(project.id)

        expect(File.mtime(config_path)).not_to be_nil
        expect { subject }.not_to change { File.mtime(config_path) }
      end
    end
  end
end
