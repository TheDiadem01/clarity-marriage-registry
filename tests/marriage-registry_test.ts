import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test adding officiants",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const officiant = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('marriage-registry', 'add-officiant', 
                [types.principal(officiant.address)], 
                deployer.address
            )
        ]);
        
        block.receipts[0].result.expectOk();
    }
});

Clarinet.test({
    name: "Test marriage registration",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const officiant = accounts.get('wallet_1')!;
        const partner1 = accounts.get('wallet_2')!;
        const partner2 = accounts.get('wallet_3')!;
        
        // First add officiant
        chain.mineBlock([
            Tx.contractCall('marriage-registry', 'add-officiant', 
                [types.principal(officiant.address)], 
                deployer.address
            )
        ]);
        
        // Register marriage
        let block = chain.mineBlock([
            Tx.contractCall('marriage-registry', 'register-marriage',
                [
                    types.principal(partner1.address),
                    types.principal(partner2.address)
                ],
                officiant.address
            )
        ]);
        
        block.receipts[0].result.expectOk();
        
        // Verify marriage status
        let verifyBlock = chain.mineBlock([
            Tx.contractCall('marriage-registry', 'is-married',
                [types.principal(partner1.address)],
                deployer.address
            )
        ]);
        
        assertEquals(verifyBlock.receipts[0].result, types.bool(true));
    }
});
