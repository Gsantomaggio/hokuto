defmodule RabbitmqInt do
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
  @behaviour :gen_statem
  @name :rabbitmq_gen

  def publish_message(prefix, message) do
    :gen_statem.call(@name, {:publish, Enum.join([prefix, message], "_")})
  end

  def publish_message(message) do
    :gen_statem.call(@name, {:publish, message})
  end

  def start_link() do
    :gen_statem.start_link({:local, @name}, __MODULE__, [], [])
  end

  @impl :gen_statem
  def init(_opts) do
    Blogs.log_info("New RabbitmqInt process #{inspect(self())}")
    Process.flag(:trap_exit, true)
    {
      :ok,
      :conneting,
      %{}
      #   {:next_state, :internal, :conneting}
    }

  end
  @impl :gen_statem
  def callback_mode() do
    :handle_event_function
  end

  def handle_event({:call, from}, {:publish, message}, :conneting, state) do
    Blogs.log_info("try_connection")
    # don't DO {:ok, conn} = AMQP.Connection.open
    # always use case of when handle the resouces, with :ok or :error

    case AMQP.Connection.open do
      {:ok, %AMQP.Connection{pid: pid}} -> Blogs.log_info("Connection established, PID: #{inspect(pid)}")
                                           Process.link(pid)
                                           {
                                             :next_state,
                                             :publish,
                                             state,
                                             {
                                               :next_event,
                                               {:call, from},
                                               {:publish, message}
                                             }

                                           }


      error -> Blogs.log_info("Connection error, Reason: #{inspect(error)}")
               :timer.sleep(2000)
               {:stop, :normal}
    end

  end



  @impl :gen_statem
  def handle_event({:call, from}, {:publish, message}, :publish, state) do
    Blogs.log_info(
      "current status:#{inspect(state)}, my status is:#{inspect(message)}} "
    )

    {:keep_state, state, [{:reply, from, :ok_got_it}]};
  end

  def handle_event(:info, {:EXIT, pid, reason}, v, state) do
    Blogs.log_info("********** The process:#{inspect(pid)} is dead, reason:#{inspect(reason)} ")
    # here we wait a bit before close the process
    # if RabbitMQ is down, we wait before connect it
    # again

    #show the differences with low sleep, the process won't restart
    #undestand that "let it crash" is ot the solution
    :timer.sleep(2000)
    {:stop, :normal}
  end


end