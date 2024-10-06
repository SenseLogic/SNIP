/*
    This file is part of the Snip distribution.

    https://github.com/senselogic/SNIP

    Copyright (C) 2021 Eric Pelzer (ecstatic.coder@gmail.com)

    Snip is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Snip is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Snip.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : exists, mkdirRecurse, readText, write, SpanMode;
import std.path : absolutePath;
import std.stdio : writeln;
import std.string : endsWith, indexOf, lastIndexOf, replace, split, startsWith, strip, stripRight;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

string GetPhysicalPath(
    string path
    )
{
    version( Windows )
    {
        return `\\?\` ~ path.absolutePath.replace( '/', '\\' ).replace( "\\.\\", "\\" );
    }

    return path;
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

string GetFolderPath(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ 0 .. slash_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

void CreateFolder(
    string folder_path
    )
{
    try
    {
        if ( folder_path != ""
             && folder_path != "/"
             && !folder_path.exists() )
        {
            writeln( "Creating folder : ", folder_path );

            folder_path.GetPhysicalPath().mkdirRecurse();
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    CreateFolder( file_path.GetFolderPath() );

    try
    {
        if ( !file_path.exists()
             || file_path.readText() != file_text )
        {
            writeln( "Writing file : ", file_path );

            file_path.write( file_text );
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

void ProcessFile(
    string input_file_path,
    string output_folder_path
    )
{
    bool
        line_is_inside_code;
    long
        first_line_index,
        line_index,
        output_file_path_character_index;
    string
        input_file_text,
        line,
        output_file_text,
        output_file_path;
    string[]
        line_array;

    input_file_text = input_file_path.ReadText();
    line_array = input_file_text.replace( "\r", "" ).replace( "\t", "    " ).split( '\n' );

    line_is_inside_code = false;
    first_line_index = -1;

    output_file_text = "";
    output_file_path = "";

    for ( line_index = 0;
          line_index < line_array.length;
          ++line_index )
    {
        line = line_array[ line_index ].stripRight();

        if ( line.startsWith( "```" ) )
        {
            if ( line_is_inside_code )
            {
                if ( output_file_path != "" )
                {
                    output_file_path.WriteText( output_file_text );
                }

                output_file_path = "";
            }
            else
            {
                output_file_text = "";
                first_line_index = line_index + 1;
            }

            line_is_inside_code = !line_is_inside_code;
        }
        else if ( line_is_inside_code )
        {
            if ( line_index == first_line_index
                 && ( line.startsWith( "//:" )
                      || line.startsWith( "--:" )
                      || line.startsWith( "#:" ) ) )
            {
                output_file_path_character_index = line.indexOf( ':' ) + 1;
                output_file_path = output_folder_path ~ line[ output_file_path_character_index .. $ ].strip();
            }
            else
            {
                output_file_text ~= line ~ "\n";
            }
        }
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    argument_array = argument_array[ 1 .. $ ];

    if ( argument_array.length == 2
         && argument_array[ 1 ].GetLogicalPath().endsWith( '/' ) )
    {
        ProcessFile(
            argument_array[ 0 ].GetLogicalPath(),
            argument_array[ 1 ].GetLogicalPath()
            );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    snip input_text.txt OUTPUT_FOLDER/" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
