import gradio as gr
import subprocess

# Function to check service status
def check_service_status(service_name):
    result = subprocess.run(['sudo', 'systemctl', 'is-active', service_name], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

# Function to activate the service and return the updated status
def activate_service(service_name):
    subprocess.run(['sudo', 'systemctl', 'start', service_name])
    # Deactivate the other service to ensure only one is active
    if service_name == 'comfyui.service':
        subprocess.run(['sudo', 'systemctl', 'stop', 'sdwebui.service'])
    else:
        subprocess.run(['sudo', 'systemctl', 'stop', 'comfyui.service'])
    return check_service_status(service_name), check_service_status('comfyui.service'), check_service_status('sdwebui.service')

# Function to deactivate all services
def deactivate_all_services():
    subprocess.run(['sudo', 'systemctl', 'stop', 'comfyui.service'])
    subprocess.run(['sudo', 'systemctl', 'stop', 'sdwebui.service'])
    return check_service_status('comfyui.service'), check_service_status('sdwebui.service')

# Function to check statuses initially
def check_status():
    comfyui_status = check_service_status('comfyui.service')
    sd_status = check_service_status('sdwebui.service')
    return comfyui_status, sd_status

# Gradio interface layout
with gr.Blocks() as app:
    gr.Markdown("# AI Manager")

    # Initial status check when the app loads
    comfyui_status_value, sd_status_value = check_status()

    # Status display
    comfyui_status = gr.Textbox(value=comfyui_status_value, label="Comfy UI Status", interactive=False)
    sd_status = gr.Textbox(value=sd_status_value, label="Stable Diffusion Status", interactive=False)

    # Links to the services if active
    if comfyui_status_value == "active":
        gr.Markdown("[Open ComfyUI](/)")
    if sd_status_value == "active":
        gr.Markdown("[Open Stable Diffusion](/)")

    # Buttons to activate services, only show if the service is not active
    if comfyui_status_value != "active":
        activate_comfyui_btn = gr.Button("Activate Comfy UI")
        activate_comfyui_btn.click(fn=lambda: activate_service('comfyui.service'), inputs=[], outputs=[comfyui_status, sd_status])

    if sd_status_value != "active":
        activate_sdwebui_btn = gr.Button("Activate Stable Diffusion")
        activate_sdwebui_btn.click(fn=lambda: activate_service('sdwebui.service'), inputs=[], outputs=[comfyui_status, sd_status])

    # Deactivate All button
    deactivate_all_btn = gr.Button("Deactivate All Services")
    deactivate_all_btn.click(fn=deactivate_all_services, inputs=[], outputs=[comfyui_status, sd_status])

# Launch the app on port 5000
app.launch(server_name="127.0.0.1", server_port=5000, root_path="/ai_manager")
