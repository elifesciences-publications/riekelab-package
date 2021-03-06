function filtered = highPassFilter(data, freq, sampleInterval)
    % data is a vector or matrix of row vectors. freq is in Hz. sampleInterval is in seconds.
    
    len = size(data, 2);
    if len == 1 % flip if given a column vector
        data = data';
        len = size(data, 2);
    end
    
    freqStepSize = 1/(sampleInterval * len);
    freqKeepPts = round(freq / freqStepSize);

    % Eliminate frequencies beyond cutoff (middle of matrix given fft representation).
    fftData = fft(data, [], 2);
    fftData(:,1:freqKeepPts) = 0;
    fftData(end-freqKeepPts:end) = 0;
    filtered = real(ifft(fftData, [], 2));
end