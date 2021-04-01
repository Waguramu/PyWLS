## PyWLS for BenderWu

### Requirements
* Python 3.6+
* WolframScript

This software requires WolframScript framework!
Please refer to [WolframScript](https://www.wolfram.com/wolframscript/).
Also, see [WLS Documentation](https://reference.wolfram.com/language/ref/program/wolframscript.html).

### Example
```
calc = MathematicaWFCalc(path="BenderWu_Borel_Script.wls")
calc.run_wls(params=["o=20", "p=3", "K=6", "G=0.1"])
print(calc.get_coeff())
```
