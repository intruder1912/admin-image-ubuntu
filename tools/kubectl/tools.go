//go:build tools

// Package tools pins the kubectl version installed by the Dockerfile.
//
// It is never built; the blank import keeps "go mod tidy" from dropping the
// requirement in go.mod, which is what Dependabot (gomod ecosystem) updates.
package tools

import _ "k8s.io/kubectl/pkg/util/slice"
