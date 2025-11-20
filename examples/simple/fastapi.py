import ray
from ray import serve
from fastapi import FastAPI

# Connect to remote cluster
if not ray.is_initialized():
    ray.init(address="ray://raycluster-kuberay-head-svc:10001")

serve.start(detached=True, http_options={"host": "0.0.0.0", "port": 8000})

export_app = FastAPI(
    title="Export Predictor API",
    description="Export Pipeline online inference"
)

@serve.deployment
@serve.ingress(export_app)
class HelloWorld:
    def __init__(self):
        # Load model
        self.model = "hello"

    @export_app.get("/", include_in_schema=False)
    async def hello(self):
        return "hello world"

# Deploy as Serve application
serve.run(HelloWorld.bind(), name="hello_world_app", route_prefix="/hello")

print("App 'hello_world_app' deployed at '/hello'")

#serve.shutdown()