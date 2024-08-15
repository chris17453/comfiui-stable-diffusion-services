import gradio as gr
import subprocess

# Function to check service status
def check_service_status(service_name):
    result = subprocess.run(['sudo', 'systemctl', 'is-active', service_name], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

# Function to activate the service
def activate_service(service_name):
    subprocess.run(['sudo', 'systemctl', 'start', service_name])
    return check_service_status(service_name)  # Return the updated status after activation

# Function to check statuses and display them in the interface
def check_status():
    comfyui_status = check_service_status('comfyui.service')
    sd_status = check_service_status('sdwebui.service')
    return comfyui_status, sd_status

# Gradio interface layout
with gr.Blocks() as app:
    gr.Markdown("# Service Control")
    
    # Status display
    comfyui_status = gr.Textbox(label="Comfy UI Status")
    sd_status = gr.Textbox(label="Stable Diffusion Status")
    
    # Buttons to activate services
    activate_comfyui_btn = gr.Button("Activate Comfy UI")
    activate_sdwebui_btn = gr.Button("Activate Stable Diffusion")
    
    # Initial status check when the app loads
    comfyui_status_value, sd_status_value = check_status()
    comfyui_status.update(value=comfyui_status_value)
    sd_status.update(value=sd_status_value)
    
    # Button click handlers
    activate_comfyui_btn.click(fn=activate_service, inputs=[], outputs=[comfyui_status], queue=False, args=("comfyui.service",))
    activate_sdwebui_btn.click(fn=activate_service, inputs=[], outputs=[sd_status], queue=False, args=("sdwebui.service",))

# Launch the app on port 5000
app.launch(server_port=5000)
