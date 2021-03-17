package types

import (
	"math/big"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestParseChainID(t *testing.T) {
	testCases := []struct {
		name     string
		chainID  string
		expError bool
		expInt   *big.Int
	}{
		{
			"valid chain-id, single digit", "tkchain-1", false, big.NewInt(1),
		},
		{
			"valid chain-id, multiple digits", "aragonchain-256", false, big.NewInt(256),
		},
		{
			"invalid chain-id, double dash", "aragon-chain-1", true, nil,
		},
		{
			"invalid chain-id, dash only", "-", true, nil,
		},
		{
			"invalid chain-id, undefined", "-1", true, nil,
		},
		{
			"invalid chain-id, uppercases", "TKCHAIN-1", true, nil,
		},
		{
			"invalid chain-id, mixed cases", "Tkchain-1", true, nil,
		},
		{
			"invalid chain-id, special chars", "$&*#!-1", true, nil,
		},
		{
			"invalid epoch, cannot start with 0", "tkchain-001", true, nil,
		},
		{
			"invalid epoch, cannot invalid base", "tkchain-0x212", true, nil,
		},
		{
			"invalid epoch, non-integer", "tkchain-tkchain", true, nil,
		},
		{
			"invalid epoch, undefined", "tkchain-", true, nil,
		},
		{
			"blank chain ID", " ", true, nil,
		},
		{
			"empty chain ID", "", true, nil,
		},
		{
			"long chain-id", "tkchain-" + strings.Repeat("1", 40), true, nil,
		},
	}

	for _, tc := range testCases {
		chainIDEpoch, err := ParseChainID(tc.chainID)
		if tc.expError {
			require.Error(t, err, tc.name)
			require.Nil(t, chainIDEpoch)
		} else {
			require.NoError(t, err, tc.name)
			require.Equal(t, tc.expInt, chainIDEpoch, tc.name)
		}
	}
}
