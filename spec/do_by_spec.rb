require 'do_by'

describe DoBy::Note do
  before do
    allow(Time).to receive(:now) { DateTime.parse('2014-06-01 18:30') }
  end

  context "when ENABLE_DO_BY is 1" do
    before do
      ENV["ENABLE_DO_BY"] = '1'
    end

    after do
      ENV["ENABLE_DO_BY"] = nil
    end

    let(:note){instance_double 'DoBy::Note', :raise_if_overdue => false}

    it "is happy with a date in the future" do
      expect { DoBy::Note.new('foo', '2014-06-01 19:00') }.to_not raise_error
    end

    it "supports making a TODO note" do
      expect(DoBy::Note).to receive(:new).with('fix this', '2012-01-01', anything).and_return(note)
      TODO 'fix this', '2012-01-01'
    end

    it "supports making a FIXME note" do
      expect(DoBy::Note).to receive(:new).with('fix this', '2012-01-01', anything).and_return(note)
      FIXME 'fix this', '2012-01-01'
    end

    it "supports making a OPTIMIZE note" do
      expect(DoBy::Note).to receive(:new).with('fix this', '2012-01-01', anything).and_return(note)
      OPTIMIZE 'fix this', '2012-01-01'
    end

    it "is not happy with a date in the past" do
      expect { DoBy::Note.new('foo', '2014-06-01 18:00').raise_if_overdue }.
        to raise_error(DoBy::LateTask, /2014-06-01 18:00/)
    end
  end

  context 'when ENABLE_DO_BY is not defined' do
    it "doesn't do anything" do
      expect(DoBy::Note).not_to receive(:new).with('fix this', '2012-01-01')
      TODO 'fix this', '2012-01-01'
    end
  end
end
