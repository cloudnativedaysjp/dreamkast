import * as React from 'react';

export interface SpeakerProps {
    name: string
}

const Speaker: React.FC<SpeakerProps> = ({name}) => {
    return(
        <div>
            <p>{name}</p>
        </div>
    )
}

export default Speaker;