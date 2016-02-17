require 'do_by'

describe DoBy::Repository do
  before do
    #allow(Time).to receive(:now) { DateTime.parse('2014-06-01 18:30') }
  end

  let(:todo_file){__FILE__}
  let(:todo_line){__LINE__}

  let(:options){{:todo_file => todo_file, :todo_line => todo_line}}

  describe DoBy::Repository::GitBlame do

    let(:author_name){'ARTHUR NAYME'}
    let(:author_mail){'github@arthur-nayme.com'}
    let(:author_time){Time.now.to_i}
    let(:git_blame_output){"
195662c66a07a1fb38b7e5c483d654279ee30f22 1 1 1
author #{author_name}
author-mail <#{author_mail}>
author-time #{author_time}
author-tz +0200
committer Andy Waite
committer-mail <github.aw@andywaite.com>
committer-time 1400262416
committer-tz +0200
summary New gem
boundary
filename lib/do_by/version.rb
        module DoBy"
    }

    describe "#parse_blame" do

      subject(:git_blame){DoBy::Repository::GitBlame.new(todo_file, todo_line).blame}
      before{ expect_any_instance_of(DoBy::Repository::GitBlame).to receive(:exec_blame).and_return(git_blame_output) }

      it "extracts author-name and author-email" do
        expect(git_blame[:name]).to eq author_name
        expect(git_blame[:email]).to eq author_mail
      end

      it "extracts and parses the author-time" do
        expect(git_blame[:time]).to eq Time.at(author_time).to_datetime
      end
    end
  end
end
