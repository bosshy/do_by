
require 'rubocop'
require 'do_by'
require 'rubocop/cop/do_by/expired_todos'

describe RuboCop::Cop::DoBy::ExpiredTodos::Comment do

  let(:due_in_todo_str){"# TODO[@due_in 25]: refactor"}
  let(:due_in_days_todo_str){"# TODO[@due_in 25 days]: refactor"}
  let(:due_date_todo_str){"# TODO[@due_date 2015-10-10]: refactor"}
  let(:due_by_todo_str){"# TODO[@due_by 2015-10-10]: refactor"}
  let(:until_todo_str){"# TODO[@until 2015-10-10]: refactor"}
  let(:within_todo_str){"# TODO[@within 25]: refactor"}
  let(:expiring_todo_str){"# TODO[@expires]: refactor"}
  let(:unknown_keyword_todo_str){"# TODO[@unkown]: refactor"}

  let(:plain_todo_str){"# TODO: refactor"}


  describe "plain todo" do
    subject(:todo_comment){RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(plain_todo_str)}

    it "ingores plain todos" do
      expect(todo_comment.due_by?).to be_falsey
      expect(todo_comment.due_in?).to be_falsey
      expect(todo_comment.expires?).to be_falsey
    end
  end

  describe "unkown keyword" do
    subject(:todo_comment){RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(unknown_keyword_todo_str)}
    it "is handled like plain todo" do
      expect(todo_comment.due_by?).to be_falsey
      expect(todo_comment.due_in?).to be_falsey
      expect(todo_comment.expires?).to be_falsey
    end
  end


  describe "timerange todos" do
    shared_examples "timerange todo" do
      it{is_expected.to be_due_in}
      it{is_expected.not_to be_due_by}
      it{is_expected.to be_expires}
      it{expect(subject.note).to eq "refactor"}
      it{expect(subject.due_in_val).to eq 25}
    end

    describe "@within" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(within_todo_str)}
      it_behaves_like "timerange todo"
    end

    describe "@due_in" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(due_in_todo_str)}
      it_behaves_like "timerange todo"
    end

    context "'day(s)' in annotation" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(due_in_days_todo_str)}
      it_behaves_like "timerange todo"
    end

    context "additional whitespace" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new("# TODO  [  @due_in 25 ]   : refactor")}
      it_behaves_like "timerange todo"
    end

    context "missing colon" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new("# TODO[@due_in 25 days]  refactor")}
      it_behaves_like "timerange todo"
    end
  end

  describe "date todos" do
    shared_examples "date todo" do
      it{is_expected.not_to be_due_in}
      it{is_expected.to be_due_by}
      it{is_expected.to be_expires}
      it{expect(subject.note).to eq "refactor"}
    end

    describe "@until" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(until_todo_str)}
      it_behaves_like "date todo"
    end

    describe "@due_by" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(due_by_todo_str)}
      it_behaves_like "date todo"
    end

    describe "@due_date" do
      subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(due_date_todo_str)}
      it_behaves_like "date todo"
    end
  end

  describe "@expires" do
    subject{RuboCop::Cop::DoBy::ExpiredTodos::Comment.new(expiring_todo_str)}

    it "is recognized as a expiring todo" do
      expect(subject).to be_expires
      expect(subject).not_to be_due_in
      expect(subject).not_to be_due_by
      expect(subject.note).to eq "refactor"
    end


  end


end


