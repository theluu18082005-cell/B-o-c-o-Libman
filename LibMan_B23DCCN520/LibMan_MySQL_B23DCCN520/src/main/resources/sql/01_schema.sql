CREATE TABLE tblMember0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [username] VARCHAR(50) NOT NULL UNIQUE,
    [password] VARCHAR(255) NOT NULL,
    [fullName] NVARCHAR(100) NOT NULL,
    [dateOfBirth] DATE NOT NULL,
    [address] NVARCHAR(255) NOT NULL,
    [email] VARCHAR(254) NOT NULL,
    [phoneNumber] VARCHAR(20) NOT NULL
);

CREATE TABLE tblEmployee0 (
    [tblMember0id] BIGINT NOT NULL PRIMARY KEY,
    [position] NVARCHAR(100) NOT NULL,
    FOREIGN KEY ([tblMember0id]) REFERENCES tblMember0 ([id])
);

CREATE TABLE tblReader0 (
    [tblMember0id] BIGINT NOT NULL PRIMARY KEY,
    [readerCode] VARCHAR(50) NOT NULL UNIQUE,
    [readerType] NVARCHAR(50) NOT NULL,
    FOREIGN KEY ([tblMember0id]) REFERENCES tblMember0 ([id])
);

CREATE TABLE tblManager0 (
    [tblEmployee0id] BIGINT NOT NULL PRIMARY KEY,
    FOREIGN KEY ([tblEmployee0id]) REFERENCES tblEmployee0 ([tblMember0id])
);

CREATE TABLE tblLibrarian0 (
    [tblEmployee0id] BIGINT NOT NULL PRIMARY KEY,
    FOREIGN KEY ([tblEmployee0id]) REFERENCES tblEmployee0 ([tblMember0id])
);

CREATE TABLE tblLibraryCard0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [cardNumber] VARCHAR(50) NOT NULL UNIQUE,
    [cardType] NVARCHAR(50) NOT NULL,
    [registrationDate] DATE NOT NULL,
    [expirationDate] DATE NOT NULL,
    [status] NVARCHAR(50) NOT NULL,
    [tblReader0id] BIGINT NOT NULL UNIQUE,
    FOREIGN KEY ([tblReader0id]) REFERENCES tblReader0 ([tblMember0id]),
    CHECK (expirationDate >= registrationDate)
);

CREATE TABLE tblDocument0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [documentCode] VARCHAR(50) NOT NULL UNIQUE,
    [title] NVARCHAR(255) NOT NULL,
    [documentType] NVARCHAR(50) NOT NULL,
    [author] NVARCHAR(255) NOT NULL,
    [publisher] NVARCHAR(255) NOT NULL,
    [publicationYear] INT NOT NULL,
    [description] NVARCHAR(1000) NULL
);

CREATE TABLE tblLoan0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [loanCode] VARCHAR(50) NOT NULL UNIQUE,
    [loanDate] DATE NOT NULL,
    [tblReader0id] BIGINT NOT NULL,
    [tblLibrarian0id] BIGINT NOT NULL,
    FOREIGN KEY ([tblReader0id]) REFERENCES tblReader0 ([tblMember0id]),
    FOREIGN KEY ([tblLibrarian0id]) REFERENCES tblLibrarian0 ([tblEmployee0id])
);

CREATE TABLE tblReturnReceipt0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [returnReceiptCode] VARCHAR(50) NOT NULL UNIQUE,
    [returnDate] DATE NOT NULL,
    [tblReader0id] BIGINT NOT NULL,
    [tblLibrarian0id] BIGINT NOT NULL,
    FOREIGN KEY ([tblReader0id]) REFERENCES tblReader0 ([tblMember0id]),
    FOREIGN KEY ([tblLibrarian0id]) REFERENCES tblLibrarian0 ([tblEmployee0id])
);

CREATE TABLE tblSupplier0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [supplierCode] VARCHAR(50) NOT NULL UNIQUE,
    [supplierName] NVARCHAR(255) NOT NULL,
    [address] NVARCHAR(255) NOT NULL,
    [email] VARCHAR(254) NOT NULL,
    [phoneNumber] VARCHAR(20) NOT NULL
);

CREATE TABLE tblImportReceipt0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [importReceiptCode] VARCHAR(50) NOT NULL UNIQUE,
    [importDate] DATE NOT NULL,
    [tblSupplier0id] BIGINT NOT NULL,
    [tblLibrarian0id] BIGINT NOT NULL,
    FOREIGN KEY ([tblSupplier0id]) REFERENCES tblSupplier0 ([id]),
    FOREIGN KEY ([tblLibrarian0id]) REFERENCES tblLibrarian0 ([tblEmployee0id])
);

CREATE TABLE tblImportDetail0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [quantity] INT NOT NULL,
    [unitPrice] DECIMAL(18,2) NOT NULL,
    [tblImportReceipt0id] BIGINT NOT NULL,
    [tblDocument0id] BIGINT NOT NULL,
    FOREIGN KEY ([tblImportReceipt0id]) REFERENCES tblImportReceipt0 ([id]),
    FOREIGN KEY ([tblDocument0id]) REFERENCES tblDocument0 ([id]),
    UNIQUE ([tblImportReceipt0id], [tblDocument0id]),
    CHECK (quantity > 0 AND unitPrice >= 0)
);

CREATE TABLE tblDocumentCopy0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [copyCode] VARCHAR(50) NOT NULL UNIQUE,
    [condition] NVARCHAR(255) NOT NULL,
    [circulationStatus] NVARCHAR(50) NOT NULL,
    [tblImportDetail0id] BIGINT NOT NULL,
    FOREIGN KEY ([tblImportDetail0id]) REFERENCES tblImportDetail0 ([id])
);

CREATE TABLE tblLoanDetail0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [dueDate] DATE NOT NULL,
    [conditionOnLoan] NVARCHAR(255) NOT NULL,
    [tblLoan0id] BIGINT NOT NULL,
    [tblDocumentCopy0id] BIGINT NOT NULL,
    FOREIGN KEY ([tblLoan0id]) REFERENCES tblLoan0 ([id]),
    FOREIGN KEY ([tblDocumentCopy0id]) REFERENCES tblDocumentCopy0 ([id]),
    UNIQUE ([tblLoan0id], [tblDocumentCopy0id])
);

CREATE TABLE tblReturnDetail0 (
    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [conditionOnReturn] NVARCHAR(255) NOT NULL,
    [tblReturnReceipt0id] BIGINT NOT NULL,
    [tblLoanDetail0id] BIGINT NOT NULL UNIQUE,
    FOREIGN KEY ([tblReturnReceipt0id]) REFERENCES tblReturnReceipt0 ([id]),
    FOREIGN KEY ([tblLoanDetail0id]) REFERENCES tblLoanDetail0 ([id])
);

CREATE INDEX IX_Loan0_loanDate ON tblLoan0 (loanDate, id);

CREATE INDEX IX_LoanDetail0_copy ON tblLoanDetail0 (tblDocumentCopy0id, tblLoan0id);

CREATE INDEX IX_DocumentCopy0_import ON tblDocumentCopy0 (tblImportDetail0id);
