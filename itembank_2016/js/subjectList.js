var sbjListE=[
	 ['1', '', '', '1학년 1학기']
	,['2', '', '', '1학년 2학기']
	,['3', '', '', '2학년 1학기']
	,['4', '', '', '2학년 2학기']
	,['5', '', '', '3학년 1학기']
	,['6', '', '', '3학년 2학기']
	,['7', '', '', '4학년 1학기']
	,['8', '', '', '4학년 2학기']
	,['9', '', '', '5학년 1학기']
	,['10', '', '', '5학년 2학기']
	,['11', '', '', '6학년 1학기']
	,['12', '', '', '6학년 2학기']
];
var sbjListM=[
	 ['2', 'KO', 'JKW', '국어(전경원)']
	,['1', 'KO', 'LSH', '국어(이삼형)']
	,['4', 'EN', 'KSG', '영어(김성곤, 윤정미)']
	,['5', 'EN', 'LBM', '영어(이병민)']
	,['7', 'MA', 'KOK', '수학(강옥기)']
	,['8', 'MA', 'WJH', '수학(우정호, 박교식)']
	,['3', 'SO', '', '사회']
	,['9', 'HI', '', '역사']
	,['6', 'SC', '', '과학']
	,['10', 'ET', '', '도덕']
	,['11', 'TH', '', '기술‧가정']	
	,['12', 'CC', '', '한문']
];
var sbjListH=[
	 ['1', '', '', '수학'],
	 ['2', '', '', '과학']
];
var sbjSubListE=[//1과목코드, 2저자코드, 3seq, 4학년, 5학기, 6과목명, 7커리큘럼
	[
		['KO', '', '4068', '1', '1', '국어 1-1', '15'],
		['MA', '', '4001', '1', '1', '수학 1-1', '15'],
		['KO', '', '2001', '1', '1', '국어 1-1'],
		['MA', '', '2114', '1', '1', '수학 1-1']
	],
	[	
		['KO', '', '2009', '1', '2', '국어 1-2', '15'],
		['MA', '', '4125', '1', '2', '수학 1-2', '15'],
		['KO', '', '2009', '1', '2', '국어 1-2'],
		['MA', '', '2141', '1', '2', '수학 1-2']
	],
	[
		['KO', '', '4077', '2', '1', '국어 2-1', '15'],
		['MA', '',  '4031', '2', '1', '수학 2-1', '15'],
		['KO', '', '2018', '2', '1', '국어 2-1'],
		['MA', '',  '2164', '2', '1', '수학 2-1']
	],
	[
		['KO', '',  '4201', '2', '2', '국어 2-2', '15'],
		['MA', '',  '4157', '2', '2', '수학 2-2', '15'],
		['KO', '',  '2029', '2', '2', '국어 2-2'],
		['MA', '',  '2191', '2', '2', '수학 2-2']
	],
	[
		['KO', '',  '2038', '3', '1', '국어 3-1'],
		['MA', '',  '2214', '3', '1', '수학 3-1'],
		['SO', '',  '2443', '3', '1', '사회 3-1'],
		['SC', '',  '2542', '3', '1', '과학 3-1']
	],
	[
		['KO', '',  '2048', '3', '2', '국어 3-2'],
		['MA', '',  '2241', '3', '2', '수학 3-2'],
		['SO', '',  '2455', '3', '2', '사회 3-2'],
		['SC', '',  '2552', '3', '2', '과학 3-2']
	],
	[
		['KO', '',  '2057', '4', '1', '국어 4-1'],
		['MA', '',  '2266', '4', '1', '수학 4-1'],
		['SO', '',  '2467', '4', '1', '사회 4-1'],
		['SC', '',  '2561', '4', '1', '과학 4-1']
	],
	[
		['KO', '',  '2067', '4', '2', '국어 4-2'],
		['MA', '',  '2294', '4', '2', '수학 4-2'],
		['SO', '',  '2479', '4', '2', '사회 4-2'],
		['SC', '',  '2573', '4', '2', '과학 4-2']
	],
	[
		['KO', '',  '2076', '5', '1', '국어 5-1'],
		['MA', '',  '2322', '5', '1', '수학 5-1'],
		['SO', '',  '2491', '5', '1', '사회 5-1'],
		['SC', '',  '2583', '5', '1', '과학 5-1']
	],
	[
		['KO', '',  '2642', '5', '2', '국어 5-2'],
		['MA', '',  '2825', '5', '2', '수학 5-2'],
		['SO', '',  '2688', '5', '2', '사회 5-2'],
		['SC', '',  '2764', '5', '2', '과학 5-2']
	],
	[
		['KO', '',  '2095', '6', '1', '국어 6-1'],
		['MA', '',  '2387', '6', '1', '수학 6-1'],
		['SO', '',  '2517', '6', '1', '사회 6-1'],
		['SC', '',  '2614', '6', '1', '과학 6-1']
	],
	[
		['KO', '',  '2700', '6', '2', '국어 6-2'],
		['MA', '',  '2844', '6', '2', '수학 6-2'],
		['SO', '',  '2751', '6', '2', '사회 6-2'],
		['SC', '',  '2796', '6', '2', '과학 6-2']
	],
];
var sbjSubListM=[//1과목코드, 2저자코드, 3seq(UnitInfo의 첫번째단원 id값), 4학년, 5학기, 6과목명
	[
		['KO', 'JKW', '724', '1', '1', '국어①'],
		['KO', 'JKW', '749', '1', '2', '국어②'],
		['KO', 'JKW', '770', '2', '1', '국어③'],
		['KO', 'JKW', '793', '2', '2', '국어④'],
		['KO', 'JKW', '815', '3', '1', '국어⑤'],
		['KO', 'JKW', '838', '3', '2', '국어⑥']
	],
	[	
		['KO', 'LSH', '859', '1', '1', '국어①'],
		['KO', 'LSH', '893', '1', '2', '국어②'],
		['KO', 'LSH', '926', '2', '1', '국어③'],
		['KO', 'LSH', '960', '2', '2', '국어④'],
		['KO', 'LSH', '992', '3', '1', '국어⑤'],
		['KO', 'LSH', '1024', '3', '2', '국어⑥']
	],
	[
		['EN', 'KSG', '405', '1', '0', '영어①'],
		['EN', 'KSG', '428', '2', '0', '영어②'],
		['EN', 'KSG', '606', '3', '0', '영어③']
	],
	[
		['EN', 'LBM', '416', '1', '0', '영어①'],
		['EN', 'LBM', '439', '2', '0', '영어②'],
		['EN', 'LBM', '617', '3', '0', '영어③']
	],
	[
		['MA', 'KOK', '107', '1', '0', '수학①'],
		['MA', 'KOK', '197', '2', '0', '수학②'],
		['MA', 'KOK', '658', '3', '0', '수학③']
	],
	[
		['MA', 'WJH', '167', '1', '0', '수학①'],
		['MA', 'WJH', '253', '2', '0', '수학②'],
		['MA', 'WJH', '698', '3', '0', '수학③']
	],
	[
		['SO', '', '506', '1', '0', '사회①'],
		['SO', '', '548', '2', '0', '사회②']
	],
	[
		['HI', '', '451', '1', '0', '역사①'],
		['HI', '', '484', '2', '0', '역사②']
	],
	[
		['SC', '', '288', '1', '0', '과학①'],
		['SC', '', '302', '2', '0', '과학②'],
		['SC', '', '590', '3', '0', '과학③']
	],
	[
		['ET', '', '628', '1', '0', '도덕①'],
		['ET', '', '644', '2', '0', '도덕②']
	],
	[
		['TH', 'TOT', '2940', '1', '0', '기술‧가정①'],
		['TH', 'TOT', '2954', '2', '0', '기술‧가정②']
	],
	[
		['CC', 'TOT', '3210', '1', '0', '한문']
	]
];
var sbjSubListH=[//1과목코드, 2저자코드, 3seq(UnitInfo의 첫번째단원 id값), 4학년, 5학기, 6과목명
	[
		['MA', 'PGS', '4088', '1', '0', '수학', '15']
	],
	[
		['SC', 'TOT', '2890', '1', '0', '과학'],
		['PH', 'TOT', '2969', '2', '0', '물리 Ⅰ'],
		['PH', 'TOT', '2992', '3', '0', '물리 Ⅱ'],
		['CH', 'TOT', '2918', '2', '0', '화학 Ⅰ'],
		['CH', 'TOT', '3088', '3', '0', '화학 Ⅱ'],
		['BI', 'TOT', '3068', '2', '0', '생명과학Ⅰ'],
		['BI', 'TOT', '3115', '3', '0', '생명과학 Ⅱ'],
		['ES', 'TOT', '3011', '2', '0', '지구과학Ⅰ'],
		['ES', 'TOT', '3040', '3', '0', '지구과학 Ⅱ']
	]
];