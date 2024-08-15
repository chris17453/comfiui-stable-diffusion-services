from flask import Flask, render_template, redirect, url_for
import subprocess

app = Flask(__name__)

app.config['APPLICATION_ROOT'] = '/ai_manager'


def check_service_status(service_name):
    result = subprocess.run(['sudo', 'systemctl', 'is-active', service_name], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

def activate_service(service_name):
    subprocess.run(['sudo', 'systemctl', 'start', service_name])

@app.route('/')
def index():
    comfyui_status = check_service_status('comfyui.service')
    sd_status = check_service_status('sdwebui.service')
    return render_template('index.html', comfyui_status=comfyui_status, sd_status=sd_status)

@app.route('/activate/<service_name>')
def activate(service_name):
    if service_name == 'comfyui':
        activate_service('comfyui.service')
    elif service_name == 'sdwebui':
        activate_service('sdwebui.service')
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
