package armo_builtins

# Check if peer tls is enabled in etcd cluster
deny[msga] {
	etcdPod := input[_]
	result = invalid_flag(etcdPod.spec.containers[0].command)

	msga := {
		"alertMessage": "Etcd encryption for peer connection is not enabled.",
		"alertScore": 7,
		"packagename": "armo_builtins",
		"failedPaths": result.failed_paths,
		"fixPaths": result.fix_paths,
		"alertObject": {"k8sApiObjects": [etcdPod]},
	}
}

# Assume flag set only once
invalid_flag(cmd) = result {
	full_cmd = concat(" ", cmd)
	wanted = [
		["--peer-cert-file", "<path/to/tls-certificate-file.crt>"],
		["--peer-key-file", "<path/to/tls-key-file.key>"],
	]

	fix_paths = [{
		"path": sprintf("spec.containers[0].command[%d]", [count(cmd) + i]),
		"value": sprintf("%s=%s", wanted[i]),
	} |
		not contains(full_cmd, wanted[i][0])
	]

	count(fix_paths) > 0

	result = {
		"failed_paths": ["spec.containers[0].command"],
		"fix_paths": fix_paths,
	}
}
