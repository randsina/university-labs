require 'win32/taskscheduler'

class Scheduler
  include Win32
  def initialize(params, run_in_logon=false)
    path = params.first.rpartition("\\")
    @directory = path.first(2).join
    @name = path[2]

    if run_in_logon
      type = TaskScheduler::AT_LOGON
    else
      type = TaskScheduler::DAILY
      year, month, day = params[1].split('/')
      hour, minute = params[2].split(':')
    end

    @ts = TaskScheduler.new

    @trigger = {
      start_year:     year || 2015,
      start_month:    month || 5,
      start_day:      day || 1,
      start_hour:     hour || 00,
      start_minute:   minute || 00,
      trigger_type:   type
    }
  end

  def activate
    @ts.new_work_item('my_task', @trigger)
    @ts.application_name = @name
    @ts.activate('my_task')
    @ts.working_directory = @directory

    puts "App name: " + @ts.application_name
    puts "Exit code: " + @ts.exit_code.to_s
    puts "Max run time: " + @ts.max_run_time.to_s
    puts "Next run time: " + @ts.next_run_time.to_s
    puts "Priority: " + @ts.priority.to_s
    puts "Status: " + @ts.status
    puts "Trigger count: " + @ts.trigger_count.to_s
    puts "Trigger string: " + @ts.trigger_string(0)
    puts "Working directory: " + @ts.working_directory
  end

  def run
    @ts.run
  end
end

p args = ARGV
run = args.last == 'login'
task = Scheduler.new(args, run)
task.activate
