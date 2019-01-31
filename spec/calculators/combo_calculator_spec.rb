require 'app/calculators/combo_calculator'
require 'app/interactors/task_completion_interactor'
require 'app/interactors/task_sorting_interactor'

describe ComboCalculator do
  let(:user) {create :user}
  let(:task) {create :task, value: 1, recurring: true, user: user}
  
  it 'starts from 1' do
    TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
    
    calc = ComboCalculator.new(user, time: Time.new(2017,1,1,0))
    result = calc.calculate!
    
    expect(result[:combo]).to eq 1
    expect(result[:score]).to eq 1
  end
  
  it 'increments for each task completed' do
    TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
    TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,1)).process!
    
    calc = ComboCalculator.new(user, time: Time.new(2017,1,1,8))
    result = calc.calculate!
    
    expect(result[:combo]).to eq 2
    expect(result[:score]).to eq 3
  end
  
  it 'resets if a day passes with no completions' do
    TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
    TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,5)).process!
    TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,3,5)).process!
    
    calc = ComboCalculator.new(user, time: Time.new(2017,1,3,8))
    result = calc.calculate!
    
    expect(result[:score]).to eq 4
    expect(result[:combo]).to eq 1
  end
  
  describe 'daily task penalties' do
    let!(:daily_task) {create :task, value: 1, recurring: true, daily: true, user: user}
    
    it 'applies the penalty to the combo once for each daily task missed' do
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,12)).process!
      
      calc = ComboCalculator.new(user, time: Time.new(2017,1,2,8))
      expect(calc).to receive(:apply_penalty).once.and_call_original
      result = calc.calculate!
    end
    
    it 'calculates the right values' do
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,12)).process!
      
      calc = ComboCalculator.new(user, time: Time.new(2017,1,2,8))
      result = calc.calculate!
      
      expect(result[:combo]).to eq 1
      expect(result[:score]).to eq 3
      
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,2,1)).process!# s4c2
      TaskCompletionInteractor.new(task: daily_task, time: Time.new(2017,1,2,4)).process!# s6c3
      
      calc = ComboCalculator.new(user, time: Time.new(2017,1,3,8))
      expect(calc).to receive(:apply_penalty).once.and_call_original
      
      result = calc.calculate!
      expect(result[:combo]).to eq 3
      expect(result[:score]).to eq 8
    end
  end
  
  describe 'nominations' do
    let(:task2) {create :task, value: 1, recurring: false, user: user}
    let(:task3) {create :task, value: 1, recurring: false, user: user}
    
    it 'resets the combo if an essential task is missed' do
      TaskSortingInteractor.new(user: user, date: Date.new(2017,1,2), essential_task: task2, nice_task_1: task, task_order: [task2, task]).process!
      
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
      calc = ComboCalculator.new(user, time: Time.new(2017,1,1,8))
      result = calc.calculate!
      
      expect(result[:score]).to eq 3
      expect(result[:combo]).to eq 2
      
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,2,5)).process!
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,2,5)).process!
      calc = ComboCalculator.new(user, time: Time.new(2017,1,2,8))
      result = calc.calculate!
      
      expect(result[:score]).to eq 18
      expect(result[:combo]).to eq 3
      
      calc = ComboCalculator.new(user, time: Time.new(2017,1,3,8))
      result = calc.calculate!
      
      expect(result[:score]).to eq 18
      expect(result[:combo]).to eq 1
    end
    
    it 'adds 3 to the score when an essential task is completed' do
      TaskSortingInteractor.new(user: user, date: Date.new(2017,1,1), essential_task: task2, task_order: [task2]).process!
      # TaskNominationInteractor.new(task: task2, date: Date.new(2017,1,1), priority: 0).process!
      
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
      TaskCompletionInteractor.new(task: task2, time: Time.new(2017,1,1,0)).process!
      calc = ComboCalculator.new(user, time: Time.new(2017,1,1,8))
      result = calc.calculate!
      
      expect(result[:score]).to eq 9
      expect(result[:combo]).to eq 2
    end
    
    it 'adds 2 to the score when a nice to have task is completed' do
      TaskSortingInteractor.new(user: user, date: Date.new(2017,1,1), essential_task: task, nice_task_1: task2, nice_task_2: task3, task_order: [task, task2, task3]).process!
      # TaskNominationInteractor.new(task: task2, date: Date.new(2017,1,1), priority: 2).process!
      
      TaskCompletionInteractor.new(task: task, time: Time.new(2017,1,1,0)).process!
      TaskCompletionInteractor.new(task: task3, time: Time.new(2017,1,1,0)).process!
      calc = ComboCalculator.new(user, time: Time.new(2017,1,1,8))
      result = calc.calculate!
      
      expect(result[:score]).to eq 10
      expect(result[:combo]).to eq 2
    end
  end
end
