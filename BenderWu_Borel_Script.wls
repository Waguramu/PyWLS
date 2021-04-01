#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ::Input:: *)
\[Nu]=0;
o=20; Print["Default order of perturbation / BenderWu o=", o]
p=3; Print["Default Pade order / half-order of wavefunction p=", p]
K=6; Print["Default max harmonics K=", K]
G=0.1; Print["Default parameter G=", G]
argX=Range[-8.0,8.0,0.1];
g0=0;
b=1/2;

(* ::Input:: *)
If[Length[$ScriptCommandLine]>1,For[i=2,i<=Length[$ScriptCommandLine],i++,Print["Got input: ",$ScriptCommandLine[[i]]];ToExpression[$ScriptCommandLine[[i]], StandardForm]],Print["Using default parameters"]]


(* ::Input:: *)
Needs["BenderWu`"];
BW=BenderWu[x^2/2+x^4,x,\[Nu],o, Monitor->False];

(* ::Input:: *)
u[x_,y_]=x y;
R[\[CapitalICup]_]:=NIntegrate[t^b E^-t \[CapitalICup],{t,0,\[Infinity]}];


(* ::Input:: *)
Subscript[S, wave]=BWProcess[BW,OutputStyle->"Series",Order->2 p,Output->"WaveFunction"];
Subscript[WF, x]=Function[x,Evaluate[Subscript[S, wave]]];


(* ::Input:: *)
wfX=Subscript[WF, x]/@argX;
coefWFX[x_]:=CoefficientList[x,g];
AwfX=coefWFX/@wfX;


(* ::Input:: *)
For[i=1,i<=Length[AwfX],i++,For[j=1,j<=Length[AwfX[[i]]],j++,AwfX[[i]][[j]]=AwfX[[i]][[j]]/Gamma[j+b]]];
\[CapitalICup]={};
For[i=1,i<=Length[AwfX],i++,AppendTo[\[CapitalICup],Function[x,Evaluate[\!\(
\*UnderoverscriptBox[\(\[Sum]\), \(j = 0\), \(Length[AwfX[[i]]] - 1\)]\(\(AwfX[[i]]\)[[j + 1]]\
\*SuperscriptBox[\(x\), \(j\)]\)\)]]]]


(* ::Input:: *)
PadeX={};
For[i=1,i<=Length[\[CapitalICup]],i++,AppendTo[PadeX,Function[x,Evaluate[PadeApproximant[\[CapitalICup][[i]][x],{x,g0,{p,p}}]]]]];


(* ::Input:: *)
Res={};
For[i=1,i<=Length[PadeX],i++,AppendTo[Res,{E^(-(1/2) argX[[i]]^2) R[PadeX[[i]][u[G,t]]]}]];


(* ::Input:: *)
rows={};For[i=1,i<=Length[argX],i++,AppendTo[rows,"x="<>ToString[NumberForm[argX[[i]],{\[Infinity],2}]]]];
cols={"g="<>ToString[NumberForm[G,{\[Infinity],2}]]};
TableForm[Res,TableHeadings->{rows,cols}];


(* ::Input:: *)
trRes=Transpose[Res];
plots={};
For[i=1,i<=Length[trRes],i++,AppendTo[plots,Transpose[{argX,trRes[[i]]}]]];


(* ::Input:: *)
A=Map[Function[a,NIntegrate[Interpolation[plots[[1]],x] HermiteH[a,x] Exp[-(x^2/2)],{x,-\[Infinity],\[Infinity]}]/(Sqrt[\[Pi]] 2^a a!)],Range[0,K,2]];


(* ::Input:: *)
S=Sum[{(NIntegrate[Interpolation[plots[[1]],x] HermiteH[n,x] Exp[-(x^2/2)],{x,-\[Infinity],\[Infinity]}] HermiteH[n,x] Exp[-(x^2/2)])/(Sqrt[\[Pi]] 2^n n!)},{n,0,K,2}];


(* ::Input:: *)
Print[StringJoin["{", "\"coeff\":", "[", StringRiffle[A, ","], "]", ",", "\"eq\":", "\"", ToString[S, InputForm], "\"", "}"]]