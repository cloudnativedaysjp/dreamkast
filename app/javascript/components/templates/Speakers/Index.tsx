import * as React from 'react';
import Speaker, { SpeakerProps } from "../../speakers/Speaker";

export interface SpeakerTemplateProps {
    speakers: SpeakerProps[]
}

const SpeakersTemplate: React.FC<SpeakerTemplateProps> = ({speakers}) => {
    return(
        <div>
            {speakers.map(speaker => (
                <Speaker {...speaker} />
            ))}
        </div>
    )
}

export default SpeakersTemplate;