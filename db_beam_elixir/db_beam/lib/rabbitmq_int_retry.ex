defmodule RabbitmqIntRetry do
  @moduledoc false

  # RabbitmqSup.Supervisor.start_link
  #:sys.trace Process.whereis(:rabbitmq_gen), true
  #:dbg.start(); :dbg.tracer()
  #:dbg.tracer()
  #:dbg.tpl RabbitmqInt, :_ , []
  #:dbg.tpl RabbitmqInt,:publish_message, :_ , []
  #:dbg.tpl RabbitmqInt,:publish_message, :_ , [{:_, [], [{:return_trace}]}]
  #:dbg.tpl RabbitmqInt,:publish_message, 1 , [{:_, [], [{:return_trace}]}]
  #:dbg.p(:all, :c) or :dbg.p(:all, [:c,:timestamp])
  #:dbg.:dbg.stop_clear()


  # TRACE TO FILE
  #:dbg.start()
  #:dbg.tracer(:port,:dbg.trace_port(:file,'/tmp/rmqtrace_test2'))
  #:dbg.tpl RabbitmqInt, :_ , []
  #:dbg.p(:all, :c)
  #erl -eval 'dbg:trace_client(file, "/tmp/rmqtrace_test2").' > rmq

  #using recon
  #:recon_trace.calls({RabbitmqInt, :_, []}, 100)
  #:recon_trace.calls({RabbitmqInt, :_, [{:_, [], [{:return_trace}]}]}, 100)
  #:recon_trace.calls({RabbitmqInt, :publish_message, []}, 100)
  #:recon_trace.calls({RabbitmqInt, :publish_message, [{:_, [], [{:return_trace}]}]}, 100)
  #:recon_trace.clear()


  #Debug
  #:debugger.start()
  #:int.ni(RabbitmqInt)
  #:int.break(RabbitmqInt, 103)


  ## Note about the sender PID
  require Record
  @max_backoff_try 4
  @behaviour :gen_statem
  @name :rabbitmq_gen_retry

  use Bitwise
  def publish_message(prefix, message) do
    :gen_statem.cast(@name, {:publish, Enum.join([prefix, message], "_")})
  end

  def publish_message(message) do
    :gen_statem.cast(@name, {:publish, message})
  end

  def start_link() do
    :gen_statem.start_link({:local, @name}, __MODULE__, [], [])
  end

  @impl :gen_statem
  def init(_opts) do
    Blogs.log_info("new RabbitmqIntRetry process #{inspect(self())}")
    Process.flag(:trap_exit, true)
    {:ok, :conneting, current = 0}

  end
  @impl :gen_statem
  def callback_mode() do
    [:handle_event_function, :state_enter]
  end


  def handle_event(:enter, original, :limbo, current) do
    Blogs.log_info("Enter in limbo status: #{inspect(original)}, time out for #{inspect(bsl(1, current))}")
    {
      :keep_state_and_data,
      {:state_timeout, :timer.seconds(bsl(1, current)), {:backoff_complete, original}}
    }
  end

  def handle_event(:state_timeout, {:backoff_complete, original}, :limbo, current) do
    Blogs.log_info("The backoff status is completed, Original value: #{inspect(original)}")

    {:next_state, original, current + 1, }
  end


  def handle_event(:internal, _, :limbo, _) do
    {:keep_state_and_data, :postpone}
  end


  def handle_event(:enter, _, s, _) do
    Blogs.log_info("handle_event enter, data: #{inspect(s)}")
    :keep_state_and_data
  end


  def handle_event(:internal, :backoff, _, data) do
    {:next_state, :limbo, data}
  end

  def handle_event(_, {:publish, message}, :conneting, current) do
    Blogs.log_info("Trying to connect, tentative: #{inspect(current)}")
    # don't DO {:ok, conn} = AMQP.Connection.open
    # always use case of when handle the resouces, with :ok or :error

    case AMQP.Connection.open do
      {:ok, %AMQP.Connection{pid: pid}} ->
        Blogs.log_info("Connection established, PID: #{inspect(pid)}")
        Process.link(pid)
        {:next_state, :publish, current, {:next_event, :internal, {:publish, message}}}


      error when current < @max_backoff_try ->
        Blogs.log_info("Connection error, reason: #{inspect(error)}. Going to retry..")
        {:keep_state_and_data, [{:next_event, :internal, :backoff}, {:next_event, :internal, {:publish, message}}]};



      _error ->
        Blogs.log_info("Max backoff retry  reached, going to die")
        {:stop, :normal}
    end



  end



  @impl :gen_statem
  def handle_event(_, {:publish, message}, :publish, state) do
    Blogs.log_info(
      "Publising the message:#{inspect(message)}, my status is:#{inspect(state)}} "
    )
    :keep_state_and_data
  end

  def handle_event(:info, {:EXIT, pid, reason}, _, _) do
    Blogs.log_info("********** The process:#{inspect(pid)} is dead, reason:#{inspect(reason)} ")
    # here we wait a bit before close the process
    # if RabbitMQ is down, we wait before connect it
    # again

    #show the differences with low sleep, the process won't restart
    #undestand that "let it crash" is ot the solution
    {:stop, :normal}
  end


end