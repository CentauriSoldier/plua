
--========================================|
-- math.BaseXToBase10                   |
--========================================|
function math.BaseXToBase10(sInputNumber, nInputBase)
if nInputBase > 1 and nInputBase < 37 and sInputNumber ~= "" then

local tTempMathExLetters = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
local tMathExLetters = {};

	for a = 1, (nInputBase - 10) do
	tMathExLetters[a] = tTempMathExLetters[a];
	end
	
	if nInputBase < 10 then
		
		for v = 1, (10 - nInputBase) do
		nFound = String.Find(sInputNumber, ""..(10 - v).."", 1, false);
			
			if nFound ~= -1 then
			Dialog.Message("Error", "Input numbers must not exceed base value", MB_OK, MB_ICONINFORMATION, MB_DEFBUTTON1);
			MathEXerror = true;
			end
			
		end
		
	end
	
local nTotalUnused = #tTempMathExLetters - #tMathExLetters;	

	if nTotalUnused > 0 then
	tUnused = {};
	
		for b = 1, nTotalUnused do
		nFound = String.Find(sInputNumber, tTempMathExLetters[27 - b], 1, false);
		
			if nFound ~= -1 and MathEXerror ~= true then
			Dialog.Message("Error", "Input numbers must not exceed base value", MB_OK, MB_ICONINFORMATION, MB_DEFBUTTON1);
			MathEXerror = true;
			end
		
		end
		
	end
	
local tCharacters = {};
local tEquations = {};
local nLength = String.Length(sInputNumber);

	for nStringPos = 1, nLength do
	tCharacters[nStringPos] = String.Mid(sInputNumber, nLength - (nStringPos - 1), 1);
	tEquations[nStringPos] = 0;
	end

local nTotalEquations = #tEquations;
local nTotalExLetters = #tMathExLetters;
	
	for t = 1, #tCharacters do
		
		if nTotalExLetters > 0 then
		
			for u = 1, nTotalExLetters do
				
				if String.Lower(tCharacters[t]) == String.Lower(tMathExLetters[u]) then
				nCurrentNumber = u + 9;
				break;
				end
				
			end
			
		else
		nCurrentNumber = String.ToNumber(tCharacters[t]);
		end
		
	tEquations[t] = nCurrentNumber * Math.Pow(nInputBase, t - 1);
	end


local nAnswer = 0;

	for z = 1, nTotalEquations do
	nAnswer = nAnswer + tEquations[z];
	end
	
	if MathEXerror == true then
	MathEXerror = nil;
	return -1
	else
	return nAnswer
	end	

else
return nil
end

end



--========================================|
-- math.Base10ToBaseX                   |
--========================================|
function math.Base10ToBaseX(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2);
local nInputNumber = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number"});
local nOutputBase = IRLUA_PLUGIN_CheckTypes(arg, 2, {"number"});
local bMakeNegative = false;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if nOutputBase > 1 and nOutputBase < 37 and nInputNumber ~= "" and nInputNumber ~= nil then

	if nInputNumber < 0 then
	nInputNumber = nInputNumber * -1;
	bMakeNegative = true;
	end

local tMathExLetters = {
	[1] = "A";
	[2] = "B";
	[3] = "C";
	[4] = "D";
	[5] = "E";
	[6] = "F";
	[7] = "G";
	[8] = "H";
	[9] = "I";
	[10] = "J";
	[11] = "K";
	[12] = "L";
	[13] = "M";
	[14] = "N";
	[15] = "O";
	[16] = "P";
	[17] = "Q";
	[18] = "R";
	[19] = "S";
	[20] = "T";
	[21] = "U";
	[22] = "V";
	[23] = "W";
	[24] = "X";
	[25] = "Y";
	[26] = "Z";
};

local sCurrentNumber = "";
nCurrentDividend = nInputNumber;

	repeat
	tAnswer = math.Divide(nCurrentDividend, nOutputBase);
	nCurrentDividend = tAnswer.Quotient;
		
		if tAnswer.Remainder > 9 then
		tAnswer.Remainder = tMathExLetters[tAnswer.Remainder - 9];
		end
		
	sCurrentNumber = ""..tAnswer.Remainder..""..sCurrentNumber;
	until tAnswer.Quotient == 0

if bMakeNegative == true then
sCurrentNumber = "-"..sCurrentNumber;
end

return sCurrentNumber
else
return nil
end

end



--========================================| --FIX THIS....NEGATIVE NUMBERS MUST BE RETURNED AS NEGATIVE NUMBERS BUT PROCESSED AS POSITIVE NUMBERS
-- math.BaseConvert                     | --ALSO THIS DOES NOT WORK RIGHT
--========================================|
function math.BaseConvert(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 3);
local nInputNumber =IRLUA_PLUGIN_CheckTypes(arg, 1, {"string"});
local nInputBase = IRLUA_PLUGIN_CheckTypes(arg, 2, {"number"});
local nOutputBase = IRLUA_PLUGIN_CheckTypes(arg, 3, {"number"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if nInputBase > 1 and nInputBase < 37 and nOutputBase > 1 and nOutputBase < 37 then

	if nInputBase == nOutputBase then

	return nInputNumber
	else
	
	local sSubConverted = math.BaseXToBase10(nInputNumber, nInputBase);

		if sSubConverted == -1 then
		return -1
		else
		local sConverted = math.Base10ToBaseX(sSubConverted, nOutputBase);
		return sConverted
		end
		
	end

else

return nil
end

end








--===========================
-- math.DecimalColorToHex
--===========================
function math.DecimalColorToHex()
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local nColor = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number", "string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if type(nColor) == "string" then
nColor = String.ToNumber(nColor);
end

local sRet = math.Base10ToBaseX(nColor, 16);

if String.Length(sRet) == 6 then
return sRet
else
return ""
end

end



--===========================
-- math.DecimalColorToRGB
--===========================
function math.DecimalColorToRGB(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local nColor = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number", "string"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if type(nColor) == "string" then
nColor = String.ToNumber(nColor);
end

return math.HexColorToRGB(math.Base10ToBaseX(nColor, 16))
end



--========================================| FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME 
-- math.DecimalToFraction		NOT IN XML FILE          | FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME 
--========================================| FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME FIX ME 
function math.DecimalToFraction(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local nInput = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number"});
local nNegativeMultiplier = 1;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if math.IsNegative(nInput) then
nInput = -1 * nInput;
nNegativeMultiplier = -1;
end

if nInput > 0 and nInput < 1 then

local nNumerator = String.ToNumber(String.Replace(""..nInput.."", ".", "", false));
local nStringLength = String.Length(""..nNumerator.."")
local nDenominator = 1 * Math.Pow(10, nStringLength);

local tFraction = math.FractionToLowestTerms(nNumerator, nDenominator);
tFraction.nNumerator = nNegativeMultiplier * tFraction.Numerator
tFraction.nDenominator = tFraction.Denominator;
return tFraction
else
ERROR("math.DecimalToFraction", "The absolute value of the Input must be a decimal between 0 and 1.")

end
end



--========================================|
-- math.Divide                          |
--========================================|
function math.Divide(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2);
local nDividend = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number"});
local nDivisor = IRLUA_PLUGIN_CheckTypes(arg, 2, {"number"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if nDividend == 0 then
return {0, 0};
elseif nDivisor == 0 then
return {"Undefined", "Undefined"};
else
local nQuotient = Math.Floor(nDividend / nDivisor);
local nRemainder = nDividend - (nQuotient * nDivisor);
tAnswer = {};
tAnswer.Quotient = nQuotient;
tAnswer.Remainder = nRemainder;
return tAnswer
end

end







--========================================|
-- math.FractionToLowestTerms           | --THERE IS A BUG HERE THAT WILL NOT REDUCE FRACTIONS THAT ARE MOT SIMPLY DIVISIBLE (i.e 123123 / 10000000);
--========================================|
function math.FractionToLowestTerms(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2);
--!add negative fraction support
local nNumerator = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number"});
local nDenominator = IRLUA_PLUGIN_CheckTypes(arg, 2, {"number"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
tFraction = {};

if nNumerator ~= 0 and nNumerator ~= "0" and nDenominator ~= 0 and nDenominator ~= "0" then

--+++++++++++++++++++++++|||
local function Compute(fnNumerator, fnDenominator)
local tfFraction = {};
local nGCF = math.GCF(fnNumerator, fnDenominator);
tfFraction.Numerator = fnNumerator / nGCF;
tfFraction.Denominator = fnDenominator / nGCF;
return tfFraction
end
--+++++++++++++++++++++++|||

	if nNumerator > nDenominator then
	local tAnswer = math.Divide(nNumerator, nDenominator);
	local nNumerator = tAnswer.Remainder;
	tFraction.Integer = tAnswer.Quotient;
		
		if nNumerator ~= 0 then
		local tTempFraction = Compute(nNumerator, nDenominator);
		tFraction.Numerator = tTempFraction.Numerator;
		tFraction.Denominator = tTempFraction.Denominator;
		else
		tFraction.Numerator = 0;
		tFraction.Denominator = 0;
		end
				
	elseif nNumerator == nDenominator then
	tFraction.Integer = 1;
	tFraction.Numerator = 0;
	tFraction.Denominator = 0;
	
	else
	local tTempFraction = Compute(nNumerator, nDenominator);
	tFraction.Integer = 0;
	tFraction.Numerator = tTempFraction.Numerator;
	tFraction.Denominator = tTempFraction.Denominator;
	end

elseif nNumerator ~= 0 or nNumerator ~= "0" then
tFraction.Integer = 0;
tFraction.Numerator = 0;
tFraction.Denominator = 0;

elseif nDenominator ~= 0 or nDenominator ~= "0" then
tFraction.Integer = nil;
tFraction.Numerator = nil;
tFraction.Denominator = nil;

end

return tFraction
end










--========================================|
-- math.GetPrimes                       |
--========================================|
function math.GetPrimes(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 3);
local nStart = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number"});
local nEnd = IRLUA_PLUGIN_CheckTypes(arg, 2, {"number"});
local fCallback = IRLUA_PLUGIN_CheckTypes(arg, 3, {"function", "nil"});
local tPrimes = {};
local bContinue = true;
local nIndex = 0;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if nStart > 0 and nEnd > 1 and (nEnd - nStart) > 0 and math.IsInteger(nStart) and math.IsInteger(nEnd) then

	if nStart == 1 or nStart == 2 and nEnd > 3 then
	nStart = 2;

		if nEnd == 2 then
		tPrimes = {};
		tPrimes[1] = 2;
		bContinue = false;
		elseif nEnd == 3 then
		tPrimes = {};
		tPrimes[1] = 2;
		tPrimes[2] = 3;
		bContinue = false;
		else
		tPrimes = {};
		tPrimes[1] = 2;
		bContinue = true;
		end

	end
	
	if nStart == 1 or nStart == 2 and nEnd < 4 then
	tPrimes = {};
	tPrimes[1] = 2;
	tPrimes[2] = 3;
	bContinue = false;
	end
	
nIndex = #tPrimes;

	if bContinue == true then

		if math.IsEven(nStart) then
		nStart = nStart + 1;
		end

		if math.IsEven(nEnd) then
		nEnd = nEnd - 1;
		end
	
		
		if not fCallback then		

			for nCurrent = nStart, nEnd, 2 do
			local bIsPrime = true;
			
				for nTest = 3, (nCurrent - 3), 2 do
				local nQuotient = nCurrent / nTest;
					
					if nCurrent ~= nTest then
					
						if nQuotient - Math.Floor(nQuotient) == 0 then
						bIsPrime = false;
						break;
						end
							
					end
												
				end
				
				if bIsPrime == true then
				nIndex = nIndex + 1;
				tPrimes[nIndex] = nCurrent;
				end
				
			end
							
		else
		
			for nCurrent = nStart, nEnd, 2 do
			local bIsPrime = true;
			
				for nTest = 3, (nCurrent - 3), 2 do
				local nQuotient = nCurrent / nTest;
					
					if nCurrent ~= nTest then
						if nQuotient - Math.Floor(nQuotient) == 0 then
						bIsPrime = false;
						break;
						end
						
					end
											
				end
				
				if bIsPrime == true then
				nIndex = nIndex + 1;
				tPrimes[nIndex] = nCurrent;
				fCallback(nCurrent);
				end
				
			end
							
		end

	end
	
end
return tPrimes
end



--========================================|
-- math.GetPrimeFactors                 |
--========================================|
function math.GetPrimeFactors(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local nInput = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number"});
local tRet = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if not math.IsInteger(nInput) or Math.Abs(nInput) == 1 or nInput == 0 then
ERROR("GetPrimeFactors", "Input must be an integer greater or less than 1.");
end

if math.IsNegative(nInput) then
nInput = Math.Abs(nInput);
end

if not math.IsPrime(nInput) then

	local nLastNumber = nInput;
	
	repeat

		for x = 2, nLastNumber do
		local nTest = nLastNumber / x;
		
			if math.IsInteger(nTest) then
			nLastNumber = nTest;
			tRet[#tRet + 1] = x;
			
				if math.IsPrime(nLastNumber) then
				tRet[#tRet + 1] = nLastNumber;				
				end
				
			break;
			end		
		
		end
		
		
	until math.IsPrime(nLastNumber)

else
tRet[1] = nInput;
end
	
return tRet
end



--========================================|
-- math.HexColorToRGB                   |
--========================================|
function math.HexColorToRGB(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local sHexColor = IRLUA_PLUGIN_CheckTypes(arg, 1, {"string"});
if String.Length(sHexColor) == 6 then
local tLetters = {"a", "b", "c", "d", "e", "f"};
local tStrings = {};
local tColors = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
tStrings[1] = String.Lower(String.Left(sHexColor, 1));
tStrings[2] = String.Lower(String.Mid(sHexColor, 2, 1));
tStrings[3] = String.Lower(String.Mid(sHexColor, 3, 1));
tStrings[4] = String.Lower(String.Mid(sHexColor, 4, 1));
tStrings[5] = String.Lower(String.Mid(sHexColor, 5, 1));
tStrings[6] = String.Lower(String.Right(sHexColor, 1));

for nIndex, sHexValue in tStrings do

	for nLetterValue, sLetter in tLetters do
		
		if sHexValue == sLetter then
		tStrings[nIndex] = ""..(nLetterValue + 9).."";
		end
		
	end

end

tColors.Red = (String.ToNumber(tStrings[1]) * 16) + String.ToNumber(tStrings[2]);
tColors.Green = (String.ToNumber(tStrings[3]) * 16) + String.ToNumber(tStrings[4]);
tColors.Blue = (String.ToNumber(tStrings[5]) * 16) + String.ToNumber(tStrings[6]);

return tColors
else
return nil
end
end



--========================================|
-- math.Intersection                    |
--========================================|
function math.Intersection(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 2);
local tSet1 = IRLUA_PLUGIN_CheckTypes(arg, 1, {"number"});
local tSet2 = IRLUA_PLUGIN_CheckTypes(arg, 2, {"number"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tSet1 and tSet2 then
tUnion = {};
nAdder = 0;

	for nIndex1, nNumber1 in tSet1 do
	
		for nIndex2, nNumber2 in tSet2 do
			
			if nNumber1 == nNumber2 then
			nAdder = nAdder + 1;
			tUnion[nAdder] = nNumber1;
			end
				
		end
		
	end
	
return tUnion
end

end




--========================================|
-- math.LCD                             |
--========================================|
function math.LCD(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local tNumbers = IRLUA_PLUGIN_CheckTypes(arg, 1, {"table"});
local sFunction = "LCD";
local tFactorSets = {};
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

for nIndex, nNumber in tNumbers do
local sType = type(nNumber);

	if sType ~= "number" then
	ERROR(sFunction, "Item #"..nIndex..". in input table is a "..sType..".\r\nExpected a number.")
	elseif math.IsNegative(nNumber) then
	nNumber = Math.Abs(nNumber);
	end

local tFactors = math.GetPrimeFactors(nNumber);
local tTypes = {};

	--count and record each number and type of factor
	for nFactorID, nFactor in tFactors do
	local sFactor = ""..nFactor.."";
	
		if not tTypes[sFactor] then
		tTypes[sFactor] = 1;
		else
		tTypes[sFactor] = tTypes[sFactor] + 1;
		end
	
	end
	
	for sIndex, sItem in tTypes do
		
		if not tFactorSets[sIndex] then
		tFactorSets[sIndex] = sItem;
		else
			
			if sItem > tFactorSets[sIndex] then
			tFactorSets[sIndex] = sItem;
			end
			
		end
	
	end

end


local nLCD = 1;
for sIndex, nItem in tFactorSets do
nLCD = nLCD * Math.Pow(String.ToNumber(sIndex), nItem);
end

return nLCD

end



--===========================
-- math.Mode
--===========================
function math.Mode(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local tInput = IRLUA_PLUGIN_CheckTypes(arg, 1, {"table"});
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if tInput ~= nil then
local tValues = {};
local nLast = 0;


for nIndex, nValue in tInput do

	for nSubIndex, nSubValue in tInput do
	
		if nIndex < nSubIndex and nValue == nSubValue then
		
			if not tValues[""..nValue..""] then
			tValues[""..nValue..""] = {};
			tValues[""..nValue..""].Name = ""..nValue.."";
			tValues[""..nValue..""].Count = 0;
			end
			
			tValues[""..nValue..""].Count = tValues[""..nValue..""].Count + 1;
		
		elseif nIndex == nSubIndex and nIndex == #tInput and nValue == nSubValue then
		
			if not tValues[""..nValue..""] then
			tValues[""..nValue..""] = {};
			tValues[""..nValue..""].Name = ""..nValue.."";
			tValues[""..nValue..""].Count = 0;
			end
			
			tValues[""..nValue..""].Count = tValues[""..nValue..""].Count + 1;
		
		--delete all values from the table that are equal to the found identity		
		end
	
	end

end

Table.Sort(tValues);

for index, item in tValues do
Dialog.Message("", "Name = "..item.Name.."\r\nCount = "..item.Count);
end

return tValues[#tValues]
else
return nil
end
end






--===========================
-- math.NumberToTable --ADD A SECTION THAT STORES THE . IN A VALUE CALLED "POINT"
--===========================




--========================================|
-- math.NumberToWords                   |
--========================================|
function math.numbertowords(sInitialNumericInput, bUseCommas, bIsMonetary)

local tAFOnes = {};
tAFOnes[1] = "One";
tAFOnes[2] = "Two";
tAFOnes[3] = "Three";
tAFOnes[4] = "Four";
tAFOnes[5] = "Five";
tAFOnes[6] = "Six";
tAFOnes[7] = "Seven";
tAFOnes[8] = "Eight";
tAFOnes[9] = "Nine";
tAFOnes[10] = "";

local tAFTens = {};
tAFTens[1] = "";
tAFTens[2] = "Twenty";
tAFTens[3] = "Thirty";
tAFTens[4] = "Fourty";
tAFTens[5] = "Fifty";
tAFTens[6] = "Sixty";
tAFTens[7] = "Seventy";
tAFTens[8] = "Eighty";
tAFTens[9] = "Ninety";
tAFTens[10] = "";

local tAFTeens = {};
tAFTeens[1] = "Eleven";
tAFTeens[2] = "Twelve";
tAFTeens[3] = "Thirteen";
tAFTeens[4] = "Fourteen";
tAFTeens[5] = "Fifteen";
tAFTeens[6] = "Sixteen";
tAFTeens[7] = "Seventeen";
tAFTeens[8] = "Eighteen";
tAFTeens[9] = "Nineteen";
tAFTeens[10] = "Ten";

	--======================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	function SortTriad(sNumericInput, sPlaceType, bSpacePlaceType, bIsLastBlock,  bDelimitAll) --[[>>
	<<                                                                                             >>
	<<                                                                                             >>
	<<<<<<<<<<<<<<<<<<<<<========================================================================--]]
	if sNumericInput == "" or sNumericInput == nil then
	Application.ExitScript();
	end
	
	if bSpacePlaceType == true then
	sPlaceSpacer = " ";
	elseif bSpacePlaceType == false then
	sPlaceSpacer = "";
	else
	sPlaceSpacer = " ";
	end
	
	--count the numbers of numbers :)
	nTotalNumbers = String.Length(sNumericInput);
	
	--convert the string to a number
	nNumericInput = tonumber(sNumericInput);
	
	if nTotalNumbers == 3 then --if there are three numbers
	
	--this checks for an all-zero block and refuses delimiting if found
	nStrikes = 0;
	
	--isloate the first number
	sFirstNumber = String.Left(sNumericInput, 1);
	--convert it to a number
	nFirstNumber = tonumber(sFirstNumber);
	
		if nFirstNumber == 0 then
		nFirstNumber = 10;
		sAFFirstSpacer = "";
		sOneHundred = "";
		nStrikes = nStrikes + 1;
		else
		sAFFirstSpacer = " ";
		sOneHundred = "Hundred";
		end
		
	--isloate the second number
	sSecondNumber = String.Mid(sNumericInput, 2, 1);
	--convert it to a number
	nSecondNumber = tonumber(sSecondNumber);
	
		if nSecondNumber == 0 then
		nSecondNumber = 10;
		sMidItem = "SKIP";
		sAFSpacer = "";
		nStrikes = nStrikes + 1;
		elseif nSecondNumber == 1 then
		bThirdNumberIsTeen = true;
		sMidItem = "SKIP";
		sAFSpacer ="";
		else
		sMidItem = "";
		sAFSpacer = " ";
		end
	
		if sMidItem ~= "SKIP" then
		sSecondNumber = String.Mid(sNumericInput, 2, 1);
		nSecondNumber = tonumber(sSecondNumber);
		end
	
	--isloate the third number
	sThirdNumber = String.Mid(sNumericInput, 3, 1);
	--convert it to a number
	nThirdNumber = tonumber(sThirdNumber);
	
		if nThirdNumber == 0 then
		nThirdNumber = 10;
		nStrikes = nStrikes + 1;
		end
		
		if nStrikes == 3 then
		sPlaceSpacer = "";
		sPlaceType = "";
		end
		
		if bThirdNumberIsTeen == true then
		sWordOutput = tAFOnes[nFirstNumber]..sAFFirstSpacer..sOneHundred..sAFFirstSpacer..tAFTens[nSecondNumber]..sAFSpacer..tAFTeens[nThirdNumber]..sPlaceSpacer..sPlaceType;
		else
		sWordOutput = tAFOnes[nFirstNumber]..sAFFirstSpacer..sOneHundred..sAFFirstSpacer..tAFTens[nSecondNumber]..sAFSpacer..tAFOnes[nThirdNumber]..sPlaceSpacer..sPlaceType;
		end
		
		bThirdNumberIsTeen = nil;
		
	elseif nTotalNumbers == 2 then
	
	--isloate the second number
	sSecondNumber = String.Mid(sNumericInput, 1, 1);
	--convert it to a number
	nSecondNumber = tonumber(sSecondNumber);
	
		if nSecondNumber == 0 then
		nSecondNumber = 10;
		sMidItem = "SKIP";
		sAFSpacer = "";
		elseif nSecondNumber == 1 then
		bThirdNumberIsTeen = true;
		sMidItem = "SKIP";
		sAFSpacer ="";
		else
		sMidItem = "";
		sAFSpacer = " ";
		end
	
		if sMidItem ~= "SKIP" then
		sSecondNumber = String.Mid(sNumericInput, 1, 1);
		nSecondNumber = tonumber(sSecondNumber);
		end
	
	--isloate the third number
	sThirdNumber = String.Mid(sNumericInput, 2, 1);
	--convert it to a number
	nThirdNumber = tonumber(sThirdNumber);
	
		if nThirdNumber == 0 then
		nThirdNumber = 10;
		end
		
		if bThirdNumberIsTeen == true then
		sWordOutput = tAFTens[nSecondNumber]..sAFSpacer..tAFTeens[nThirdNumber]..sPlaceSpacer..sPlaceType;
		else
		sWordOutput = tAFTens[nSecondNumber]..sAFSpacer..tAFOnes[nThirdNumber]..sPlaceSpacer..sPlaceType;
		end
		
		bThirdNumberIsTeen = nil;
	
	elseif nTotalNumbers == 1 then
	
	--isloate the third number
	sThirdNumber = String.Mid(sNumericInput, 1, 1);
	--convert it to a number
	nThirdNumber = tonumber(sThirdNumber);
	
		if nThirdNumber == 0 then
		sWordOutput = "";
		else
		sWordOutput = tAFOnes[nThirdNumber]..sPlaceSpacer..sPlaceType;
		end
			
	end
	
	if nStrikes == 3 or bIsLastBlock == true or bDelimitAll == false then
	bDelimit = false;
	else
	bDelimit = true;
	end
	
	tReturnValues = {};
	tReturnValues[1] = sWordOutput;
	tReturnValues[2] = bDelimit;
	
	return tReturnValues
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	end--|||||||||||||END FUNCTION|||||||||||||||||
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local tNumberPlaces = {};
tNumberPlaces[1] = "";
tNumberPlaces[2] = "Thousand";
tNumberPlaces[3] = "Million";
tNumberPlaces[4] = "Billion";
tNumberPlaces[5] = "Trillion";
tNumberPlaces[6] = "Quadrillion";
tNumberPlaces[7] = "Quintillion";
tNumberPlaces[8] = "Sextillion";
tNumberPlaces[9] = "Septillion";
tNumberPlaces[10] = "Octillion";
tNumberPlaces[11] = "Nonillion";
tNumberPlaces[12] = "Decillion";
tNumberPlaces[13] = "Undecillion";
tNumberPlaces[14] = "Duodecillion";
tNumberPlaces[15] = "Tredecillion";
tNumberPlaces[16] = "Quattuordecillion";
tNumberPlaces[17] = "Quindecillion";
tNumberPlaces[18] = "Sexdecillion";
tNumberPlaces[19] = "Septendecillion";
tNumberPlaces[20] = "Octodecillion";
tNumberPlaces[21] = "Novemdecillion";
tNumberPlaces[22] = "Vigintillion";
tNumberPlaces[23] = "Centillion";

--eliminate any commas the user may have typed
sInitialNumericInput = string.gsub(sInitialNumericInput, ",", "");

--look for a negative sign
nNegativeSign = string.find(sInitialNumericInput, "-", 1);
if nNegativeSign then
sInitialNumericInput = string.gsub(sInitialNumericInput, "-", "");
sNegativeSign = "Negative ";
else
sNegativeSign = "";
end

--check for a decimal place
nDecimalPlace = string.find(sInitialNumericInput, ".", 1);

if nDecimalPlace then --if there is a decimal place found
sLeftSide = string.sub(sInitialNumericInput, 1, string.len(sInitialNumericInput) - (string.len(sInitialNumericInput) - nDecimalPlace) - 1);
sRightSide = string.right(sInitialNumericInput, (string.len(sInitialNumericInput) - nDecimalPlace));
	--make sure that we multiply by ten any number that is single (e.g. 1,234.3)
	if string.len(sRightSide) == 1 then
	nRightSide = tonumber(sRightSide) * 10;
	sRightSide = tostring(nRightSide);
	end
	
else
sLeftSide = sInitialNumericInput;
sRightSide = "IGNORE";
end

--get the number values of our string
nLeftSide = tonumber(sLeftSide);

--count the number of numbers in the input
nTotalLeftNumbers = string.len(sLeftSide);
--count the number blocks 
nTotalBlocks = math.ceil(nTotalLeftNumbers / 3);

--create the table to hold the number blocks
tNumberBlocks = {};
for nPlaceHolder = 1, nTotalBlocks do
tNumberBlocks[nPlaceHolder] = "";
end

sRemainingBlocks = sLeftSide;

for x = 1, nTotalBlocks do
	
	if x ~= nTotalBlocks then
	local nRBLength = string.len(sRemainingBlocks);
	--string.sub(sRemainingBlocks, string.len(sRemainingBlocks), 4);
	--get the block from the main input string
	--this used string.right(sRemainingBlocks, 3)
	sBlock = string.sub(sRemainingBlocks, nRBLength - 2);
	
	sRemainingBlocks = string.sub(sRemainingBlocks, 1, nRBLength - 3);
		
	--store it into the block table
	tNumberBlocks[nTotalBlocks - x + 1] = sBlock;

	elseif x == nTotalBlocks then
	
	--store the last block
	tNumberBlocks[nTotalBlocks - x + 1] = sRemainingBlocks;
	
	end

end

sOutput = "";

for x = 1, nTotalBlocks do
	if x ~= nTotalBlocks then
	sBlockSpacer = " ";
	bSpacer = true;
	bLastNumberBlock = false;
		if bUseCommas == true then
		bDelimitMe = true;
		else
		bDelimitMe = false;
		end
	elseif x == nTotalBlocks then
	sBlockSpacer = "";
	bSpacer = false;
	bLastNumberBlock = true;
	bDelimitMe = false;
	end

tReturns = SortTriad(tNumberBlocks[x], tNumberPlaces[nTotalBlocks - x + 1], bSpacer, bLastNumberBlock, bUseCommas);
sWords = tReturns[1];

if tReturns[2] == true and bDelimitMe == true then
sDeliminator = ",";
elseif tReturns[2] == false or bDelimitMe == false then
sDeliminator = "";
end

sOutput = sOutput..sWords..sDeliminator..sBlockSpacer;

end

--add the dollars tag if the user chooses
if bIsMonetary == true then
	
	bNoDollars = false;
	
	if sLeftSide == "0" or sLeftSide == "" then
	bNoDollars = true;
	elseif sLeftSide == "1" then
	sOutput = sOutput.." Dollar"
	else
	sOutput = sOutput.." Dollars"
	end
	
end


--right side of the decimal place
if sRightSide ~= "IGNORE" then

local tRightNumbers = {};
tRightNumbers[1] = "One";
tRightNumbers[2] = "Two";
tRightNumbers[3] = "Three";
tRightNumbers[4] = "Four";
tRightNumbers[5] = "Five";
tRightNumbers[6] = "Six";
tRightNumbers[7] = "Seven";
tRightNumbers[8] = "Eight";
tRightNumbers[9] = "Nine";
tRightNumbers[10] = "Zero";

sEndString = "";

nRightSide = tonumber(sRightSide);

nTotalRightNumbers = string.len(sRightSide);

sRemainingNumbers = sRightSide; 

	for x = 1, nTotalRightNumbers do
		
		if x ~= nTotalRightNumbers then
		sDecimalSpacer = " ";
		elseif x == nTotalRightNumbers then
		sDecimalSpacer = "";
		end
	
	--get the first number from the right side string
	sEndNumber = string.sub(sRemainingNumbers, 1, 1);
	--convert it to a number
	nEndNumber = tonumber(sEndNumber);
	
		if nEndNumber == 0 then
		nEndNumber = 10;
		end
		
	sRemainingNumbers = string.right(sRemainingNumbers, string.len(sRemainingNumbers) - 1);
		
	--concatenate the strings
	sEndString = sEndString..tRightNumbers[nEndNumber]..sDecimalSpacer;
	end

	if bIsMonetary == true then
	--isolate each number
	sChangeTens = string.sub(sRightSide, 1, 1);
	sChangeOnes = string.sub(sRightSide, 2, 1);
	--convert then to number values
	nChangeTens = tonumber(sChangeTens);
	nChangeOnes = tonumber(sChangeOnes);
	
	sCloseString = " Cents.";
	if bNoDollars == false then
	sAnd = " and ";
	elseif bNoDollars == true then
	sAnd = "";
	end
	
		if nChangeTens == 0 and nChangeOnes == 0 then
		sEndString = "";
		sCloseString = "";
		sAnd = "";
		elseif nChangeTens == 0 and nChangeOnes == 1 then
		sEndString = tAFOnes[nChangeOnes];
		sCloseString = " Cent.";
		elseif nChangeTens == 0 and nChangeOnes ~= 0 and nChangeOnes ~= 1 then
		sEndString = tAFOnes[nChangeOnes];
		elseif nChangeTens == 1 and nChangeOnes == 0 then
		sEndString = tAFTeens[10];
		elseif nChangeTens == 1 and nChangeOnes ~= 0 then
		sEndString = tAFTeens[nChangeOnes];
		elseif nChangeTens ~= 0 and nChangeTens ~= 1 and nChangeOnes == 0 then
		sEndString = tAFTens[nChangeTens];
		elseif nChangeTens ~= 0 and nChangeTens ~= 1 and nChangeOnes ~= 0 then
		sEndString = tAFTens[nChangeTens].." "..tAFOnes[nChangeOnes];
		end
		
	sOutput = sOutput..sAnd..sEndString..sCloseString;
	
	else
	
	sOutput = sOutput.." Point "..sEndString;
	
	end
	
end

--if there is a double space then delete it.
sOutput = string.gsub(sOutput, "  ", " ");

--there is gremlin in the code that puts a comma at the end of the output string when a single number block is used.
--Since I have spent a few hours and still can't track down the bug, I have built the following gremlin-killing code block.
nFound = string.sub(sOutput, string.len(sOutput) - 5);
if nFound then
--sOutput = string.sub(sOutput, 1, nFound - 1);
end

sOutput = sNegativeSign..sOutput;

return sOutput
end





--========================================|
-- math.RGBColorToHex                   |
--========================================|
function math.RGBColorToHex(...)
IRLUA_PLUGIN_CheckNumArgs(arg, 1);
local tRGB = IRLUA_PLUGIN_CheckTypes(arg, 1, {"table"});
local bContinue = true;
local sHex = "";
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


if #tRGB ~= 3 then
bContinue = false;
end

if bContinue then 

	for nIndex, nColor in tRGB do
		
		if type(nColor) ~= "number" then
		bContinue = false;
		end
	
	end

end

if bContinue then
	
	for nIndex, nColor in tRGB do
	sHex = sHex..math.Base10ToBaseX(nColor, 16);
	end
	
end

if bContinue then

	if String.Length(sHex) ~= 6 then
	sHex = "";
	end

end

return sHex
end



