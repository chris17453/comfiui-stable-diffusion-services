import gradio as gr
import subprocess
import time

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
    # Delay before checking status to allow services to start/stop
    time.sleep(5)  # Adjust the delay time as needed

    return check_service_status(service_name), check_service_status('comfyui.service'), check_service_status('sdwebui.service')

# Function to deactivate all services
def deactivate_all_services():
    subprocess.run(['sudo', 'systemctl', 'stop', 'comfyui.service'])
    subprocess.run(['sudo', 'systemctl', 'stop', 'sdwebui.service'])
    # Delay before checking status to allow services to stop
    time.sleep(5)  # Adjust the delay time as needed

    return check_service_status('comfyui.service'), check_service_status('sdwebui.service')

# Function to check statuses
def check_status():
    comfyui_status = check_service_status('comfyui.service')
    sd_status = check_service_status('sdwebui.service')
    return comfyui_status, sd_status

# Gradio interface layout
with gr.Blocks() as app:
    gr.Markdown("# AI Manager")

    # Status display
    comfyui_status = gr.Textbox(label="Comfy UI Status", interactive=False)
    sd_status = gr.Textbox(label="Stable Diffusion Status", interactive=False)

    # Function to refresh the status
    def refresh_status():
        return check_status()

    # Initial status check and update on every page refresh
    comfyui_status_value, sd_status_value = check_status()
    comfyui_status.update(value=comfyui_status_value)
    sd_status.update(value=sd_status_value)

    # Links to the services if active
    comfyui_link = gr.Markdown("[Open ComfyUI](/)", visible=comfyui_status_value == "active")
    sd_link = gr.Markdown("[Open Stable Diffusion](/)", visible=sd_status_value == "active")

    # Buttons to activate services
    activate_comfyui_btn = gr.Button("Activate Comfy UI")
    activate_comfyui_btn.click(fn=lambda: activate_service('comfyui.service'), inputs=[], outputs=[comfyui_status, sd_status])

    activate_sdwebui_btn = gr.Button("Activate Stable Diffusion")
    activate_sdwebui_btn.click(fn=lambda: activate_service('sdwebui.service'), inputs=[], outputs=[comfyui_status, sd_status])

    # Deactivate All button
    deactivate_all_btn = gr.Button("Deactivate All Services")
    deactivate_all_btn.click(fn=deactivate_all_services, inputs=[], outputs=[comfyui_status, sd_status])

    # Ensure status is refreshed on each click
    activate_comfyui_btn.click(fn=refresh_status, inputs=[], outputs=[comfyui_status, sd_status])
    activate_sdwebui_btn.click(fn=refresh_status, inputs=[], outputs=[comfyui_status, sd_status])
    deactivate_all_btn.click(fn=refresh_status, inputs=[], outputs=[comfyui_status, sd_status])

    # Set up a Timer to periodically refresh the status
    status_refresh_timer = gr.Timer(refresh_status, interval=10, outputs=[comfyui_status, sd_status])

# Launch the app on port 5000
app.launch(server_name="127.0.0.1", server_port=5000, root_path="/ai_manager")
