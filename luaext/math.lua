--[[ 
Version History

Version 1.1.0.0
Updated the IRLua Plugin Helper Functions
Fixed XML readout order
Added new functions:
	math.createcounter()
	math.getcounterpos()
	math.getprimes()
	math.iseven()
	math.isprime()
	math.stepcounter()

Version 1.2.0.0
Updated the IRLua Plugin Helper Functions
Added new functions:
	math.getprimefactors()
	math.lcd()
	
Version 1.3.0.0
Fixed a bug in math.basextobase10()
Fixed a bug in math.fractiontodecimal()
Added new functions:
	math.log() --Allows the input of the log base (where the stock AMS action "Math.Log" does not).
	math.ln()
	
Version 1.4.0.0
Updated the IRLua Plugin Helper Functions (v2.4)
Added new functions:
	math.coefficientofvariation()
	math.decimalcolortohex()
	math.decimalcolortorgb()
	math.fivesummarydata()
	math.hexcolortorgb()
	math.mean()
	math.median()
	math.mode()
	math.numbercount()
	math.numbertotable()
	math.range()
	math.rgbcolortohex()
	math.standarddeviation()
	math.summation()
	math.variance()
	
	
Version 1.5.0.0
Fixed a bug in the math.variance() function

Version 1.6.0.0
Updated the IRLua Plugin Helper Functions (v2.5)
Added new functions:

Fixed Bugs in/Improved Functions:
	math.getprimes()
	math.iseven()
	math.integer()
	math.negative()

Version 2.0.0.0
Converted plugin to pure lua
Removed IRLua Plugin Helper Functions for speed
Made all functions lower case to align style with lua
Removed math.sortnumericdatabase function
Added math.factorial() function.

Version 2.0.0.1
Fixed a bug in and added return types for the math.factorial() function.




TODO
--Add math.solvetrianle({a,A,b,B,c,C})
fix the divide function by using the modulus function

RadiansToDegrees
DegreesToRadians
PolarToRect
RectToPolar
Imaginary and Complex number functions


]]

local tCounters = {};
local e = 2.71828182845904523536028747135266249775724709369995957496696762772407663035354759457138217852516642742746639193200305992181741359662904357290033429526059563073813232862794349076323382988075319525101901157383418793070215408914993488416750924476146066808226480016847741185374234544243710753907774499206955170276183860626133138458300075204493382656029760673711320070932870912744374704723069697720931014169283681902551510865746377211125238978442505695369677078544996996794686445490598793163688923009879312773617821542499922957635148220826989519366803318252886939849646510582093923982948879332036250944311730123819706841614039701983767932068328237646480429531180232878250981945581530175671736133206981125099618188159304169035159888851934580727386673858942287922849989208680582574927961048419844436346324496848756023362482704197862320900216099023530436994184914631409343173814364054625315209618369088870701676839642437814059271456354906130310720851038375051011574770417189861068739696552126715468895703503;
local pi = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273724587006606315588174881520920962829254091715364367892590360011330530548820466521384146951941511609433057270365759591953092186117381932611793105118548074462379962749567351885752724891227938183011949129833673362440656643086021394946395224737190702179860943702770539217176293176752384674818467669405132000568127145263560827785771342757789609173637178721468440901224953430146549585371050792279689258923542019956112129021960864034418159813629774771309960518707211349999998372978049951059731732816096318595024459455346908302642522308253344685035261931188171010003137838752886587533208381420617177669147303598253490428755468731159562863882353787593751957781857780532171226806613001927876611195909216420198;
	
	--+++++++++++++++++++++++|||
	local function LCMCompute(fnFirst, fnSecond)
	for x = 2, fnSecond do
		
		for y = 1, x do
		
			if (x * fnFirst) == (y * fnSecond) then
			return (x * fnFirst)
			end
		
		end
		
	end
	end
	--+++++++++++++++++++++++|||

	--+++++++++++++++++++++++++++++++THIS MAY BE NATIVE LUA
	local function sort(nItem1, nItem2, bAscending)
		
		if bAscending == true then
			
			if nItem1 - nItem2 > 0 then
			return true
			
			else
			return false
			
			end
			
		else
		
			if nItem1 - nItem2 < 0 then
			return true
			
			else
			return false
			
			end
		
		end
	
	end
	--+++++++++++++++++++++++++++++++


	
function math.coefficientofvariation(tInput)
return (math.standarddeviation(tInput) / math.mean(tInput)) * 100
end


	
function math.createcounter(nMaxCount, bUse0Based)
local nCounterID = #tCounters + 1;
local nStart = 1;
local nMax = nMaxCount;

if bUse0Based then
nStart = 0;
nMax = nMax - 1;
end

tCounters[nCounterID] = {
	Start = nStart,
	Current = nStart,
	Max = nMax,
};

return nCounterID
end



function math.factorial(nInput, sRequestedReturnType)
local tOld = {1};
local sReturnType = "number";
local sTypeRequestedReturnType = type(sRequestedReturnType);

	if sTypeRequestedReturnType == "string" then
	sReturnType = "string";
	
	elseif sTypeRequestedReturnType == "table" then
	sReturnType = "table";
	
	end

	for nFactorial = 2, nInput do
	local tNew = {};
	local nRemainder = 0;
	local nOldCount = #tOld;	
	
		for nIndex = nOldCount, 1, -1 do		
		local nResult = (nFactorial * tOld[nIndex]) + nRemainder;
				
			if nResult < 10 then
			table.insert(tNew, 1, nResult);
			nRemainder = 0;
							
			else			
			local sResult = tostring(nResult);
			local nLength = string.len(nResult);
			nRemainder = tonumber(string.sub(sResult, 1, nLength - 1));
			table.insert(tNew, 1, tonumber(string.sub(sResult, nLength)));
									
			end
			
			if nIndex == 1 then
				
				if nRemainder > 0 then
				local sInput = tostring(nRemainder);
												
					for x = string.len(sInput), 1, -1  do
					table.insert(tNew, 1, tonumber(string.sub(sInput, x, x)));
					end
				
				end
				
			end	
					
		end
		
		tOld = {};
		
		for nIndex, nValue in pairs(tNew) do
		tOld[nIndex] = nValue;
		end		
			
	end
	
	if sReturnType == "table" then
	return tOld
	
	else
	local sRet = "";
	
		for nIndex,  nValue in pairs(tOld) do
		sRet = sRet..nValue;
		end
		
		if sReturnType == "string" then
		return sRet
			
		elseif sReturnType == "number" then
		return tonumber(sRet)
			
		end
		
	end		
	
end



function math.fivesummarydata(tInput)--?
table.sort(tInput, true);

local tQ = {};
local nN = #tInput;

	if nN > 4 then
	tQ[1] = tInput[1];
	tQ[2] = tInput[Math.Ceil(0.25 * nN)];
	tQ[3] = tInput[Math.Ceil(0.5 * nN)];
	tQ[4] = tInput[Math.Ceil(0.75 * nN)];
	tQ[5] = tInput[#tInput];

	return tQ
	end

end



function math.getcounterpos(nCounterID)
return tCounters[nCounterID].Current
end



function math.iseven(nNumber)
local nAbsNumber = math.abs(nNumber) / 2;

	if nAbsNumber - math.floor(nAbsNumber) == 0 then
	return true
	end

return false
end



function math.isinteger(nNumber)
local nAbsNumber = math.abs(nNumber);

	if nAbsNumber - math.floor(nAbsNumber) == 0 then
	return true
	end

return false
end



function math.isprime(nInput)
local bRet = false;

	if nInput > 2 and math.isinteger(nInput) and not math.iseven(nInput) then
	bRet = true;

		for n = 3, (nInput - 1), 2 do
		local nQuotient = nInput / n;
			
			if nQuotient - math.floor(nQuotient) == 0 then
			bRet = false;
			break;
			end
		
		end

	elseif nInput == 2 then
	bRet = true;
	end

return bRet
end



function math.gcf(nFirst, nSecond)
nFirst = math.abs(nFirst);
nSecond = math.abs(nSecond);

	if (nFirst - nSecond)  < 0 then
	return (nFirst * nSecond) / math.lcm(nFirst, nSecond)

	elseif (nFirst - nSecond) >= 0 then
	return (nFirst * nSecond) / math.lcm(nSecond, nFirst)
	
	end

end



function math.lcm(nFirst, nSecond)
nFirst = math.abs(nFirst);
nSecond = math.abs(nSecond);

	if nFirst < nSecond then
	return LCMCompute(nFirst, nSecond);
	
	elseif nFirst >= nSecond then
	return LCMCompute(nSecond, nFirst);
	
	end

end



function math.len(nInput, bIncludeDecimalPoint)
local sInput = tostring(nInput);
	
	if not bIncludeDecimalPoint then
	sInput = string.gsub(sInput, ".", "");
	end
	
return string.len(sInput)
end



function math.ln(nInput)
	
	if nInput < 0 then
	return math.Log(e, nInput)	 
	end

end



function math.mean(tInput)
return math.summation(tInput) / #tInput;
end



function math.median(tInput)
local nMedian = -1;
local nMid = #tInput / 2;

table.sort(tInput, true);

	if math.iseven(#tInput) then
	nMedian = (tInput[nMid] + tInput[nMid + 1]) / 2
	
	else
	nMedian = tInput[math.cCeil(nMid)];
	
	end

return nMedian
end



function math.totable(nInput)--make this handle negative numbers
local tRet = {};
local sInput = tostring(nInput);
--sInput = string.gsub(sInput, ".", ""); --FIX THIS LATER
local nTotalDigits = string.len(sInput);

	for x = 1, nTotalDigits do
	tRet[x] = tonumber(string.sub(sInput, x, x));
	end

return tRet
end



function math.range(tInput)
table.sort(tInput, true);

return tInput[#tInput] - tInput[1]
end



function math.standarddeviation(tInput)
local nN = #tInput;
local nSummation = math.summation(tInput);
local nSquaredSummation = 0;

	for nIndex, nValue in pairs(tInput) do
	nSquaredSummation = nSquaredSummation + (nValue ^ 2);
	end

return math.sqrt(((nN * nSquaredSummation) - (nSummation ^ 2)) / (nN * (nN - 1)));

end



function math.stepcounter(nCounterID)
local nRet = -1;

	if tCounters[nCounterID] then
	local nStart = tCounters[nCounterID].Start;
	local nCurrent = tCounters[nCounterID].Current;
	local nMax = tCounters[nCounterID].Max;
	

		if nCurrent == nMax then
		tCounters[nCounterID].Current = nStart;
		nRet = nStart;
		
		else
		tCounters[nCounterID].Current = nCurrent + 1;
		nRet = nCurrent + 1;
		
		end

	end
	
return nRet
end



function math.summation(tInput)
local nTotal = 0;

	for nIndex, nValue in pairs(tInput) do
	nTotal = nTotal + nValue;
	end

	return nTotal

end



function math.variance(tInput)
return math.standarddeviation(tInput) ^ 2;
end