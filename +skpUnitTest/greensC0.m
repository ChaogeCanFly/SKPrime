classdef greensC0 < matlab.unittest.TestCase
%greensC0 is the test class for G0.

% E. Kropf, 2016
% 
% This file is part of SKPrime.
% 
% SKPrime is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% SKPrime is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with SKPrime.  If not, see <http://www.gnu.org/licenses/>.

properties
    dv = [-0.2517+0.3129i; 0.2307-0.4667i]
    qv = [0.2377; 0.1557]
    alpha = -0.4863-0.37784i

    domain
    innerBdryPoints
    innerPoint
    
    prodLevel = 6
    wprod
    g0prod
    g0hatProd
    
    g0object
end

methods(TestClassSetup)
    function simpleDomain(test)
        wp = skprod(test.dv, test.qv, test.prodLevel);
        test.wprod = wp;
        test.g0prod = @(z,a) ...
            log(wp(z, a)./wp(z, 1/conj(a))/abs(a))/2i/pi;
        test.g0hatProd = @(z,a) test.g0prod(z, a) ...
            - log((z - a)./(z - 1/conj(a)))/2i/pi;
        
        test.domain = skpDomain(test.dv, test.qv);
        test.innerBdryPoints = boundaryPts(test.domain, 5);
        test.innerPoint = 0.66822-0.11895i;
        
        test.g0object = greensC0(test.alpha, test.domain);
    end
end

methods(Test)
    function hatAlphaOffBoundary(test)
        g0 = test.g0object;
        test.compareAllPoints(...
            @(z) test.g0hatProd(z, test.alpha), @g0.hat, 1e-5)
    end
    
    function alphaOffBoundary(test)
        g0 = test.g0object;
        
        test.compareAllPoints(...
            @(z) test.g0prod(z, test.alpha), g0, 1e-5)
    end
    
    function diffVarHatAlphaOffBoundary(test)
        g0 = test.g0object;
        
        d2g0h = diffh(g0, 2);
        d3g0h = diffh(g0, 3);
        
        h = 1e-6;
        d3ref = @(z) (d2g0h(z + h) - d2g0h(z - h))/2/h;
        
        test.compareAllPoints(d3ref, d3g0h, 1e-6)
    end
    
    function diffVarAlphaOffBoundary(test)
        g0 = test.g0object;
        
        d2g0 = diff(g0, 2);
        d3g0 = diff(g0, 3);
        
        h = 1e-6;
        d3ref = @(z) (d2g0(z + h) - d2g0(z - h))/2/h;
        
        test.compareAllPoints(d3ref, d3g0, 1e-6)
    end
end

methods
    function compareAllPoints(test, ref, fun, tol)
        testPointCell = {
            test.innerBdryPoints, 'inner boundary'
            test.innerPoint, 'inner point'
            };
        
        for i = 1:size(testPointCell, 1)
            [z, str] = testPointCell{i,:};
            err = ref(z) - fun(z);
            test.verifyLessThan(max(abs(err(:))), tol, ...
                sprintf('Absolute error > %.1e on %s check.', tol, str))
        end
    end
end

end
