class Admin::SessionQuestionAnswersController < ApplicationController
  include SecuredAdmin

  def destroy
    @session_question = @conference.session_questions.find(params[:session_question_id])
    @answer = @session_question.session_question_answers.find(params[:id])

    if @answer.destroy
      flash[:notice] = '回答を削除しました'
    else
      flash[:alert] = '回答の削除に失敗しました'
    end

    redirect_to admin_session_question_path(@session_question, event: params[:event])
  end
end
