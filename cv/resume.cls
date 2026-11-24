%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Medium Length Professional CV - RESUME CLASS FILE
%
% This template has been downloaded from:
% http://www.LaTeXTemplates.com
%
% This class file defines the structure and design of the template.
%
% Original header:
% Copyright (C) 2010 by Trey Hunner
%
% Copying and distribution of this file, with or without modification,
% are permitted in any medium without royalty provided the copyright
% notice and this notice are preserved. This file is offered as-is,
% without any warranty.
%
% Created by Trey Hunner and modified by www.LaTeXTemplates.com
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2010/07/10 v0.9 Resume class]
\LoadClass[11pt,letterpaper]{article}

\RequirePackage[skip=5pt plus 1pt,parfill]{parskip}
\RequirePackage{array}
\RequirePackage{ifthen}
\RequirePackage{needspace}
\RequirePackage{xcolor}
\RequirePackage[left=0.4in,top=0.3in,right=0.4in,bottom=0.3in]{geometry}

\pagestyle{empty}
\definecolor{resumeAccent}{cmyk}{0.58,0.90,0,0}

\newcommand{\@resumename}{}
\newcommand{\@resumeaddresses}{}

\newcommand{\name}[1]{\def\@resumename{#1}}
\newcommand{\address}[1]{%
  \g@addto@macro\@resumeaddresses{\@printresumeaddress{#1}}%
}

\newcommand{\@printresumeaddress}[1]{%
  \begingroup
  \renewcommand{\\}{$\diamond$\ \ignorespaces}%
  \centerline{#1}%
  \endgroup
  \par\smallskip
}

\newcommand{\makeresumeheader}{%
  \par\begingroup
  \setlength{\parfillskip}{0pt plus 1fil}%
  \noindent
  \makebox[\linewidth][c]{\huge\textbf{\@resumename}}\par
  \smallskip
  \@resumeaddresses
  \endgroup
}

\newenvironment{resumeSection}[2][4]{%
  \needspace{#1\baselineskip}%
  \medskip
  \textcolor{resumeAccent}{\MakeUppercase{#2}}%
  \medskip
  \hrule
  \begin{list}{}{\setlength{\leftmargin}{0pt}}%
    \item[]%
}{%
  \end{list}%
}

% Supply the entry title, date, and subtitle. Leave the subtitle empty to omit it.
\newenvironment{resumeEntry}[3]{%
  \needspace{4\baselineskip}%
  % The line break removes the final space, leaving one space after the date.
  \textbf{#1} \hfill {#2}\space\space
  \ifthenelse{\equal{#3}{}}{}{\\\emph{#3}}%
  \begin{list}{$\cdot$}{%
    \setlength{\leftmargin}{1em}%
    \setlength{\itemsep}{-0.5em}%
    \vspace{-0.5em}%
  }%
}{%
  \end{list}%
}
