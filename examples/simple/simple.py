import ray
from ray import serve
from starlette.requests import Request

# Connect to remote cluster
if not ray.is_initialized():
    ray.init(address="ray://raycluster-kuberay-head-svc:10001")

serve.start(detached=True, http_options={"host": "0.0.0.0", "port": 8000})

@serve.deployment
class HelloWorld:
    def __init__(self):
        # Load model
        self.model = "hello"

    async def __call__(self, http_request: Request) -> str:
        return "hello world"

# Deploy as Serve application
serve.run(HelloWorld.bind(), name="hello_world_app", route_prefix="/hello")

print("App 'hello_world_app' deployed at '/hello'")

#serve.shutdown()