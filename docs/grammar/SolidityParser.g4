/**
 * Solidity adalah bahasa tingkat tinggi yang diketik secara statis, berorientasi pada kontrak, untuk menerapkan smart kontrak pada platform Ethereum.
 */
parser grammar SolidityParser;

options { tokenVocab=SolidityLexer; }

/**
 * Dalam top level, Solidity mengizinkan pragmas, import directives, dan
 * definitions of contracts, interfaces, libraries, structs, enums dan constants.
 */
sourceUnit: (
	pragmaDirective
	| importDirective
	| contractDefinition
	| interfaceDefinition
	| libraryDefinition
	| functionDefinition
	| constantVariableDeclaration
	| structDefinition
	| enumDefinition
	| userDefinedValueTypeDefinition
	| errorDefinition
)* EOF;

//@doc: inline
pragmaDirective: Pragma PragmaToken+ PragmaSemicolon;

/**
 * Import directives import identifiers file yang berbeda.
 */
importDirective:
	Import (
		(path (As unitAlias=identifier)?)
		| (symbolAliases From path)
		| (Mul As unitAlias=identifier From path)
	) Semicolon;
//@doc: inline
//@doc:name aliases
importAliases: symbol=identifier (As alias=identifier)?;
/**
 * Jalur file yang akan diimport.
 */
path: NonEmptyStringLiteral;
/**
 * Daftar alias untuk simbol yang akan diimport.
 */
symbolAliases: LBrace aliases+=importAliases (Comma aliases+=importAliases)* RBrace;

/**
 * Definisi Top-level sebuah kontrak.
 */
contractDefinition:
	Abstract? Contract name=identifier
	inheritanceSpecifierList?
	LBrace contractBodyElement* RBrace;
/**
 * Definisi Top-level sebuah interface.
 */
interfaceDefinition:
	Interface name=identifier
	inheritanceSpecifierList?
	LBrace contractBodyElement* RBrace;
/**
 * Definisi Top-level sebuah library.
 */
libraryDefinition: Library name=identifier LBrace contractBodyElement* RBrace;

//@doc:inline
inheritanceSpecifierList:
	Is inheritanceSpecifiers+=inheritanceSpecifier
	(Comma inheritanceSpecifiers+=inheritanceSpecifier)*?;
/**
 * Penentu Inheritance untuk kontrak dan interface.
 * Secara opsional dapat menyediakan argumen basis konstruktor.
 */
inheritanceSpecifier: name=identifierPath arguments=callArgumentList?;

/**
 * Deklarasi yang dapat digunakan dalam kontrak, interface, dan library.
 *
 * Perhatikan bahwa interfaces dan library mungkin tidak berisi konstruktor, interfaces mungkin tidak berisi variabel state
 * dan library tidak boleh berisi fallback, menerima fungsi atau variabel state non-konstan.
 */
contractBodyElement:
	constructorDefinition
	| functionDefinition
	| modifierDefinition
	| fallbackFunctionDefinition
	| receiveFunctionDefinition
	| structDefinition
	| enumDefinition
	| userDefinedValueTypeDefinition
	| stateVariableDeclaration
	| eventDefinition
	| errorDefinition
	| usingDirective;
//@doc:inline
namedArgument: name=identifier Colon value=expression;
/**
 * Argumen saat memanggil fungsi atau objek callable serupa.
 * Argumen diberikan sebagai daftar yang dipisahkan koma atau sebagai peta argumen bernama.
 */
callArgumentList: LParen ((expression (Comma expression)*)? | LBrace (namedArgument (Comma namedArgument)*)? RBrace) RParen;
/**
 * Nama yang memenuhi syarat.
 */
identifierPath: identifier (Period identifier)*;

/**
 * Panggilan ke modifikator. Jika pengubah tidak mengambil argumen, daftar argumen dapat dilewati seluruhnya
 * (termasuk tanda kurung buka dan tutup).
 */
modifierInvocation: identifierPath callArgumentList?;
/**
 * Visibilitas untuk fungsi dan tipe fungsi.
 */
visibility: Internal | External | Private | Public;
/**
 * Daftar parameter, seperti argumen fungsi atau nilai return.
 */
parameterList: parameters+=parameterDeclaration (Comma parameters+=parameterDeclaration)*;
//@doc:inline
parameterDeclaration: type=typeName location=dataLocation? name=identifier?;
/**
 * Definisi konstruktor.
 * Harus selalu menyediakan implementasi.
 * Perhatikan bahwa menentukan visibilitas internal atau publik tidak lagi digunakan.
 */
constructorDefinition
locals[boolean payableSet = false, boolean visibilitySet = false]
:
	Constructor LParen (arguments=parameterList)? RParen
	(
		modifierInvocation
		| {!$payableSet}? Payable {$payableSet = true;}
		| {!$visibilitySet}? Internal {$visibilitySet = true;}
		| {!$visibilitySet}? Public {$visibilitySet = true;}
	)*
	body=block;

/**
 * State mutabilitas untuk tipe fungsi.
 * Mutabilitas default 'non-payable' diasumsikan jika tidak ada mutabilitas yang ditentukan.
 */
stateMutability: Pure | View | Payable;
/**
 * Sebuah specifier override digunakan untuk fungsi, modifier atau variabel state.
 * Dalam kasus di mana ada pernyataan ambigu dalam beberapa basis kontrak yang diganti,
 * daftar lengkap basis kontrak harus diberikan.
 */
overrideSpecifier: Override (LParen overrides+=identifierPath (Comma overrides+=identifierPath)* RParen)?;
/**
 * Definisi kontrak, library and fungsi interface.
 * Tergantung pada konteks di mana fungsi didefinisikan, pembatasan lebih lanjut mungkin berlaku,
 * misalnya fungsi dalam interface harus tidak diimplementasikan, yaitu tidak boleh berisi tubuh blok.
 */
functionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	Function (identifier | Fallback | Receive)
	LParen (arguments=parameterList)? RParen
	(
		{!$visibilitySet}? visibility {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	 )*
	(Returns LParen returnParameters=parameterList RParen)?
	(Semicolon | body=block);
/**
 * Definisi modifier.
 * Perhatikan bahwa di dalam tubuh blok modifier, garis bawah tidak dapat digunakan sebagai pengenal,
 * tetapi digunakan sebagai pernyataan pengganti untuk isi fungsi yang modifier-nya diterapkan.
 */
modifierDefinition
locals[
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	Modifier name=identifier
	(LParen (arguments=parameterList)? RParen)?
	(
		{!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	)*
	(Semicolon | body=block);

/**
 * Definisi fungsi fallback khusus.
 */
fallbackFunctionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false,
	boolean hasParameters = false
]
:
	kind=Fallback LParen (parameterList { $hasParameters = true; } )? RParen
	(
		{!$visibilitySet}? External {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	)*
	( {$hasParameters}? Returns LParen returnParameters=parameterList RParen | {!$hasParameters}? )
	(Semicolon | body=block);

/**
 * Definisi fungsi receive khusus.
 */
receiveFunctionDefinition
locals[
	boolean visibilitySet = false,
	boolean mutabilitySet = false,
	boolean virtualSet = false,
	boolean overrideSpecifierSet = false
]
:
	kind=Receive LParen RParen
	(
		{!$visibilitySet}? External {$visibilitySet = true;}
		| {!$mutabilitySet}? Payable {$mutabilitySet = true;}
		| modifierInvocation
		| {!$virtualSet}? Virtual {$virtualSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
	 )*
	(Semicolon | body=block);

/**
 * Definisi dari sebuah struct. Dapat terjadi di tingkat atas dalam unit sumber atau dalam kontrak, library, atau interface.
 */
structDefinition: Struct name=identifier LBrace members=structMember+ RBrace;
/**
 * The declaration of a named struct member.
 */
structMember: type=typeName name=identifier Semicolon;
/**
 * Definisi dari sebuah enum. Dapat terjadi di tingkat atas dalam unit sumber atau dalam kontrak, library, atau interface.
 */
enumDefinition:	Enum name=identifier LBrace enumValues+=identifier (Comma enumValues+=identifier)* RBrace;
/**
 * Definisi dari sebuah tipe user defined value. Dapat terjadi di tingkat atas dalam unit sumber atau dalam kontrak, library, atau interface.
 */
userDefinedValueTypeDefinition:
	Type name=identifier Is elementaryTypeName[true] Semicolon;

/**
 * Deklarasi variabel state.
 */
stateVariableDeclaration
locals [boolean constantnessSet = false, boolean visibilitySet = false, boolean overrideSpecifierSet = false]
:
	type=typeName
	(
		{!$visibilitySet}? Public {$visibilitySet = true;}
		| {!$visibilitySet}? Private {$visibilitySet = true;}
		| {!$visibilitySet}? Internal {$visibilitySet = true;}
		| {!$constantnessSet}? Constant {$constantnessSet = true;}
		| {!$overrideSpecifierSet}? overrideSpecifier {$overrideSpecifierSet = true;}
		| {!$constantnessSet}? Immutable {$constantnessSet = true;}
	)*
	name=identifier
	(Assign initialValue=expression)?
	Semicolon;

/**
 * Deklarasi variabel konstan.
 */
constantVariableDeclaration
:
	type=typeName
	Constant
	name=identifier
	Assign initialValue=expression
	Semicolon;

/**
 * Parameter suatu event.
 */
eventParameter: type=typeName Indexed? name=identifier?;
/**
 * Definisi dari suatu event. Dapat terjadi di kontrak, library atau interface.
 */
eventDefinition:
	Event name=identifier
	LParen (parameters+=eventParameter (Comma parameters+=eventParameter)*)? RParen
	Anonymous?
	Semicolon;

/**
 * Parameter kesalahan.
 */
errorParameter: type=typeName name=identifier?;
/**
 * Definisi kesalahan.
 */
errorDefinition:
	Error name=identifier
	LParen (parameters+=errorParameter (Comma parameters+=errorParameter)*)? RParen
	Semicolon;

/**
 * Menggunakan direktif untuk mengikat fungsi library ke tipe.
 * Dapat terjadi dalam kontrak dan library.
 */
usingDirective: Using identifierPath For (Mul | typeName) Semicolon;
/**
 * Nama tipe dapat berupa tipe dasar, tipe fungsi, tipe mapping, tipe user-defined
 * (misalnya kontrak atau struct) atau tipe array.
 */
typeName: elementaryTypeName[true] | functionTypeName | mappingType | identifierPath | typeName LBrack expression? RBrack;
elementaryTypeName[boolean allowAddressPayable]: Address | {$allowAddressPayable}? Address Payable | Bool | String | Bytes | SignedIntegerType | UnsignedIntegerType | FixedBytes | Fixed | Ufixed;
functionTypeName
locals [boolean visibilitySet = false, boolean mutabilitySet = false]
:
	Function LParen (arguments=parameterList)? RParen
	(
		{!$visibilitySet}? visibility {$visibilitySet = true;}
		| {!$mutabilitySet}? stateMutability {$mutabilitySet = true;}
	)*
	(Returns LParen returnParameters=parameterList RParen)?;

/**
 * Deklarasi variabel tunggal.
 */
variableDeclaration: type=typeName location=dataLocation? name=identifier;
dataLocation: Memory | Storage | Calldata;

/**
 * Ekspresi kompleks.
 * Dapat berupa akses indeks, akses rentang indeks, akses anggota, panggilan fungsi (dengan opsi panggilan fungsi opsional),
 * konversi tipe, ekspresi unary atau biner, perbandingan atau penetapan, ekspresi ternary,
 * ekspresi baru (yaitu pembuatan kontrak atau alokasi array memori dinamis),
 * Tuple, inline array, atau ekspresi utama (yaitu pengidentifikasi, literal, atau nama tipe).
 */
expression:
	expression LBrack index=expression? RBrack # IndexAccess
	| expression LBrack start=expression? Colon end=expression? RBrack # IndexRangeAccess
	| expression Period (identifier | Address) # MemberAccess
	| expression LBrace (namedArgument (Comma namedArgument)*)? RBrace # FunctionCallOptions
	| expression callArgumentList # FunctionCall
	| Payable callArgumentList # PayableConversion
	| Type LParen typeName RParen # MetaType
	| (Inc | Dec | Not | BitNot | Delete | Sub) expression # UnaryPrefixOperation
	| expression (Inc | Dec) # UnarySuffixOperation
	|<assoc=right> expression Exp expression # ExpOperation
	| expression (Mul | Div | Mod) expression # MulDivModOperation
	| expression (Add | Sub) expression # AddSubOperation
	| expression (Shl | Sar | Shr) expression # ShiftOperation
	| expression BitAnd expression # BitAndOperation
	| expression BitXor expression # BitXorOperation
	| expression BitOr expression # BitOrOperation
	| expression (LessThan | GreaterThan | LessThanOrEqual | GreaterThanOrEqual) expression # OrderComparison
	| expression (Equal | NotEqual) expression # EqualityComparison
	| expression And expression # AndOperation
	| expression Or expression # OrOperation
	|<assoc=right> expression Conditional expression Colon expression # Conditional
	|<assoc=right> expression assignOp expression # Assignment
	| New typeName # NewExpression
	| tupleExpression # Tuple
	| inlineArrayExpression # InlineArray
 	| (
		identifier
		| literal
		| elementaryTypeName[false]
	  ) # PrimaryExpression
;

//@doc:inline
assignOp: Assign | AssignBitOr | AssignBitXor | AssignBitAnd | AssignShl | AssignSar | AssignShr | AssignAdd | AssignSub | AssignMul | AssignDiv | AssignMod;
tupleExpression: LParen (expression? ( Comma expression?)* ) RParen;
/**
 * Ekspresi inline array menunjukkan array berukuran statis dari tipe umum dari ekspresi yang terkandung.
 */
inlineArrayExpression: LBrack (expression ( Comma expression)* ) RBrack;

/**
 * Selain identifier non-kata kunci biasa, beberapa kata kunci seperti 'from' dan 'error' juga dapat digunakan sebagai identifier.
 */
identifier: Identifier | From | Error | Revert;

literal: stringLiteral | numberLiteral | booleanLiteral | hexStringLiteral | unicodeStringLiteral;
booleanLiteral: True | False;
/**
 * Literal string penuh terdiri dari satu atau beberapa string yang dikutip secara berurutan.
 */
stringLiteral: (NonEmptyStringLiteral | EmptyStringLiteral)+;
/**
 * Sebuah literal string hex penuh yang terdiri dari satu atau beberapa string hex berturut-turut.
 */
hexStringLiteral: HexString+;
/**
 * Literal string unicode penuh yang terdiri dari satu atau beberapa string unicode berurutan.
 */
unicodeStringLiteral: UnicodeStringLiteral+;

/**
 * Angka literal dapat berupa angka desimal atau heksadesimal dengan unit opsional.
 */
numberLiteral: (DecimalNumber | HexNumber) NumberUnit?;
/**
 * Blok pernyataan dengan kurung kurawal. Membuka ruang lingkupnya sendiri.
 */
block:
	LBrace ( statement | uncheckedBlock )* RBrace;

uncheckedBlock: Unchecked block;

statement:
	block
	| simpleStatement
	| ifStatement
	| forStatement
	| whileStatement
	| doWhileStatement
	| continueStatement
	| breakStatement
	| tryStatement
	| returnStatement
	| emitStatement
	| revertStatement
	| assemblyStatement
;

//@doc:inline
simpleStatement: variableDeclarationStatement | expressionStatement;
/**
 * Pernyataan if dengan bagian else opsional.
 */
ifStatement: If LParen expression RParen statement (Else statement)?;
/**
 * Untuk pernyataan dengan init opsional, kondisi dan bagian post-loop.
 */
forStatement: For LParen (simpleStatement | Semicolon) (expressionStatement | Semicolon) expression? RParen statement;
whileStatement: While LParen expression RParen statement;
doWhileStatement: Do statement While LParen expression RParen Semicolon;
/**
 * Pernyataan lanjutan. Hanya diperbolehkan di dalam loop for, while atau do-while.
 */
continueStatement: Continue Semicolon;
/**
 * Pernyataan break. Hanya diperbolehkan di dalam loop for, while atau do-while.
 */
breakStatement: Break Semicolon;
/**
 * Pernyataan try. Ekspresi yang terkandung harus berupa panggilan fungsi eksternal atau pembuatan kontrak.
 */
tryStatement: Try expression (Returns LParen returnParameters=parameterList RParen)? block catchClause+;
/**
 * Klausa catch dari pernyataan try.
 */
catchClause: Catch (identifier? LParen (arguments=parameterList) RParen)? block;

returnStatement: Return expression? Semicolon;
/**
 * Pernyataan emit. Ekspresi yang terkandung perlu merujuk ke suatu event.
 */
emitStatement: Emit expression callArgumentList Semicolon;
/**
 * Pernyataan refert. Ekspresi yang terkandung perlu merujuk ke kesalahan.
 */
revertStatement: Revert expression callArgumentList Semicolon;
/**
 * Blok inline assembly.
 * Isi blok inline assembly menggunakan pemindai/lexer terpisah, yaitu kumpulan kata kunci dan
 * identifier yang diizinkan berbeda di dalam blok inline assembly.
 */
assemblyStatement: Assembly AssemblyDialect? AssemblyLBrace yulStatement* YulRBrace;

//@doc:inline
variableDeclarationList: variableDeclarations+=variableDeclaration (Comma variableDeclarations+=variableDeclaration)*;
/**
 * Tuple nama variabel yang akan digunakan dalam deklarasi variabel.
 * Dapat berisi bidang kosong.
 */
variableDeclarationTuple:
	LParen
		(Comma* variableDeclarations+=variableDeclaration)
		(Comma (variableDeclarations+=variableDeclaration)?)*
	RParen;
/**
 * Pernyataan deklarasi variabel.
 * Sebuah variabel tunggal dapat dideklarasikan tanpa nilai awal, sedangkan sebuah tupel variabel hanya dapat
 * dideklarasikan dengan nilai awal.
 */
variableDeclarationStatement: ((variableDeclaration (Assign expression)?) | (variableDeclarationTuple Assign expression)) Semicolon;
expressionStatement: expression Semicolon;

mappingType: Mapping LParen key=mappingKeyType DoubleArrow value=typeName RParen;
/**
 * Hanya tipe dasar atau tipe yang ditentukan pengguna yang layak sebagai kunci mapping.
 */
mappingKeyType: elementaryTypeName[false] | identifierPath;

/**
 * Pernyataan Yul dalam blok inline assembly.
 * pernyataan continue dan break hanya valid dalam perulangan for.
 * Pernyataan leave hanya valid di dalam badan fungsi.
 */
yulStatement:
	yulBlock
	| yulVariableDeclaration
	| yulAssignment
	| yulFunctionCall
	| yulIfStatement
	| yulForStatement
	| yulSwitchStatement
	| YulLeave
	| YulBreak
	| YulContinue
	| yulFunctionDefinition;

yulBlock: YulLBrace yulStatement* YulRBrace;

/**
 * Deklarasi satu atau lebih variabel Yul dengan nilai awal opsional.
 * Jika beberapa variabel dideklarasikan, hanya pemanggilan fungsi yang merupakan nilai awal yang valid.
 */
yulVariableDeclaration:
	(YulLet variables+=YulIdentifier (YulAssign yulExpression)?)
	| (YulLet variables+=YulIdentifier (YulComma variables+=YulIdentifier)* (YulAssign yulFunctionCall)?);

/**
 * Ekspresi apa pun dapat ditetapkan ke satu variabel Yul, sedangkan
 * multi-assignment memerlukan panggilan fungsi di sisi kanan.
 */
yulAssignment: yulPath YulAssign yulExpression | (yulPath (YulComma yulPath)+) YulAssign yulFunctionCall;

yulIfStatement: YulIf cond=yulExpression body=yulBlock;

yulForStatement: YulFor init=yulBlock cond=yulExpression post=yulBlock body=yulBlock;

//@doc:inline
yulSwitchCase: YulCase yulLiteral yulBlock;
/**
 * Pernyataan Yul switch hanya dapat terdiri dari huruf besar-default (tidak digunakan lagi) atau
 * satu atau lebih kasus non-default secara opsional diikuti oleh kasus default.
 */
yulSwitchStatement:
	YulSwitch yulExpression
	(
		(yulSwitchCase+ (YulDefault yulBlock)?)
		| (YulDefault yulBlock)
	);

yulFunctionDefinition:
	YulFunction YulIdentifier
	YulLParen (arguments+=YulIdentifier (YulComma arguments+=YulIdentifier)*)? YulRParen
	(YulArrow returnParameters+=YulIdentifier (YulComma returnParameters+=YulIdentifier)*)?
	body=yulBlock;

/**
 * Meskipun hanya pengidentifikasi tanpa titik yang dapat dideklarasikan dalam inline assembly,,
 * jalur yang berisi titik dapat merujuk ke deklarasi di luar blok inline assembly,.
 */
yulPath: YulIdentifier (YulPeriod YulIdentifier)*;
/**
 * Panggilan ke fungsi dengan nilai return hanya dapat terjadi sebagai sisi kanan tugas atau
 * deklarasi variabel.
 */
yulFunctionCall: (YulIdentifier | YulEVMBuiltin) YulLParen (yulExpression (YulComma yulExpression)*)? YulRParen;
yulBoolean: YulTrue | YulFalse;
yulLiteral: YulDecimalNumber | YulStringLiteral | YulHexNumber | yulBoolean | YulHexStringLiteral;
yulExpression: yulPath | yulFunctionCall | yulLiteral;
