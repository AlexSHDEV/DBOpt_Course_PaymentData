CREATE NONCLUSTERED INDEX iPaymentCategory_CostByMaterial
ON dbo.PaymentCategory (CostByMaterial)
INCLUDE (Oid, Name, OptimisticLockField, GCRecord, ProfitByMaterial, NotInPaymentParticipantProfit)
GO

CREATE NONCLUSTERED INDEX iPaymentCategory_ProfitByMaterial
ON dbo.PaymentCategory (ProfitByMaterial)
INCLUDE (Oid, Name, OptimisticLockField, GCRecord, CostByMaterial, NotInPaymentParticipantProfit)
GO

CREATE NONCLUSTERED INDEX iAccountType_name
ON dbo.AccountType (Name)
INCLUDE (Oid, OptimisticLockField, GCRecord)
GO
