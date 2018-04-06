defmodule DsProcesses do
  @moduledoc false



  def f() do

    receive do
      {:msg, msg} -> Blogs.log_info("Got message: #{msg}")
                     f()
      {:close} -> Blogs.log_info("Good bye")

    end

  end


  def monitor_f(pid) do
    ref = Process.monitor(pid)
    Blogs.log_info("Monitor Ref: #{inspect(ref)}")
    receive do
      {:DOWN, monitor_reference, :process, pid, reason} ->
        Blogs.log_info(
          "I am the monitor for pid: #{inspect(pid)}, pid down reason:#{inspect(reason)}, ref #{
            inspect(inspect(monitor_reference))
          } "
        )
    end

  end






  # won't delete the chain, but handle the Exit flag.
  def sup_f() do
    Process.flag(:trap_exit, true) # %% can apply more than one time, it is always one
    pid = spawn_link(&f/0)
    pid_monitor = spawn(DsProcesses, :monitor_f, [pid])
    Blogs.log_info(
      "TEE - The sup PID is: #{inspect(self())}, pid f is #{inspect(pid)},  pid monitor:#{inspect(pid_monitor)}"
    )

    receive do
      {:EXIT, b, reason} ->
        Blogs.log_info("TEE - Received 'EXIT' message pid:#{inspect(b)} Reason:#{inspect(reason)}")
        case reason do
          :normal -> Blogs.log_info("TEE - Stopped normally")
          value -> Blogs.log_info("TEE - Unexpected Stop #{value} going to restart it ~n")
                   sup_f() #%% This is for restart
        end

      value -> Blogs.log_info("sup_f :#{inspect(value)}")
    end
  end



  # send(pid("0.116.0"), {:msg, "ciao"})
  # try with exit(PID, normal)
  # and with exit(PID, my_error)
  def spawn_sup_f() do
    spawn(&sup_f/0)
  end







  # diffent between process flag and not, chain delete
  #try to kill the super here to see the chain delete
  def sup_f_no() do
    pid = spawn_link(&f/0)
    pid_monitor = spawn(DsProcesses, :monitor_f, [pid])
    Blogs.log_info(
      "TED - The sup PID is: #{inspect(self())} and the f is PIDF:#{inspect(pid)} PID_Monitor:#{inspect(pid_monitor)}"
    ) # note the self() is always the same
    receive do
      value -> Blogs.log_info("sup_f_no #{inspect(value)}")
    end

  end

  def spawn_sup_f_no() do
    spawn(&sup_f_no/0)
  end



  def spawn_with_dictonary() do
    :proc_lib.spawn(&f/0)
  end


end