package armo_builtins

# Check if --auto-tls is not set to true
deny[msga] {
	etcdPod := input[_]
    commands := etcdPod.spec.containers[0].command
    result := invalid_flag(commands)
	
	msga := {
		"alertMessage": "Auto tls is enabled. Clients are able to use self-signed certificates for TLS.",
		"alertScore": 6,
		"packagename": "armo_builtins",
		"failedPaths": result.failed_paths,
		"fixPaths":result.fix_paths,
		"alertObject": {
			"k8sApiObjects": [etcdPod],
		
		}
	}
}


invalid_flag(cmd) = result {
	contains(cmd[i], "--auto-tls=true")
	fixed = replace(cmd[i], "--auto-tls=true", "--auto-tls=false")
	path := sprintf("spec.containers[0].command[%d]", [i])
	result = {
		"failed_paths": [path],
		"fix_paths": [{"path": path, "value": fixed}],
	}
}